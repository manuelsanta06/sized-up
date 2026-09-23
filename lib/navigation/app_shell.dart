import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/calendar/presentation/calendar_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/notes/presentation/note_editor_page.dart';
import '../features/people/presentation/people_page.dart';
import '../features/notes/presentation/notes_page.dart';
import 'app_section.dart';
import 'quick_action.dart';
import 'search_query_provider.dart';

class AppShell extends ConsumerStatefulWidget{
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState()=>_AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>{
  int _selectedIndex=1;
  bool _isNavigationBarVisible=true;
  bool _isSearchOpen=false;
  AppSection? _quickMenuSection;
  List<QuickAction> _quickActions=const[];
  List<GlobalKey> _quickActionKeys=const[];
  int? _hoveredActionIndex;
  bool _quickMenuDragActive=false;
  final _searchController=TextEditingController();
  final _searchFocusNode=FocusNode();

  final List<Widget> _pages=const[CalendarPage(),NotesPage(),PeoplePage()];

  AppSection get _selectedSection=>AppSection.values[_selectedIndex];

  @override
  void dispose(){
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          appBar:AppBar(
            automaticallyImplyLeading:false,
            leading:IconButton(
              tooltip:_isSearchOpen?'Close search':'Search',
              onPressed:_isSearchOpen?_closeSearch:_openSearch,
              icon:AnimatedSwitcher(
                duration:const Duration(milliseconds:180),
                child:Icon(_isSearchOpen?Icons.close:Icons.search,key:ValueKey(_isSearchOpen)),
              ),
            ),
            title:AnimatedSwitcher(
              duration:const Duration(milliseconds:180),
              transitionBuilder:(child,animation)=>FadeTransition(opacity:animation,child:child),
              child:_isSearchOpen? TextField(
                key:const ValueKey('search-field'),
                controller:_searchController,
                focusNode:_searchFocusNode,
                textInputAction:TextInputAction.search,
                decoration:InputDecoration(
                  hintText:'Search ${_selectedSection.title.toLowerCase()}',
                  border:InputBorder.none,
                  enabledBorder:InputBorder.none,
                  focusedBorder:InputBorder.none,
                ),
                onChanged:(query)=>ref.read(searchQueryProvider(_selectedSection).notifier).update(query),
              ):Text(_selectedSection.title,key:const ValueKey('section-title')),
            ),
            actions:[
              IconButton(
                tooltip:'Account and settings',
                onPressed:_openSettings,
                icon:const Icon(Icons.account_circle_outlined)
              ),
              const SizedBox(width:8),
            ],
          ),
          body:NotificationListener<UserScrollNotification>(
            onNotification: _handleScrollNotification,
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          bottomNavigationBar: _buildNavigationBar(context),
        ),
        if (_quickMenuSection != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 96,
            child: IgnorePointer(
              ignoring: _quickMenuDragActive,
              child: _QuickActionMenu(
                section: _quickMenuSection!,
                actions: _quickActions,
                actionKeys: _quickActionKeys,
                hoveredActionIndex: _hoveredActionIndex,
                onActionTap: _selectQuickAction,
              ),
            ),
          ),
      ],
    );
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse &&
        _isNavigationBarVisible) {
      setState(() => _isNavigationBarVisible = false);
    } else if (notification.direction == ScrollDirection.forward &&
        !_isNavigationBarVisible) {
      setState(() => _isNavigationBarVisible = true);
    }
    return false;
  }

  Widget _buildNavigationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: AnimatedSlide(
        offset: _isNavigationBarVisible ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isNavigationBarVisible ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: Material(
            color: colorScheme.surfaceContainerHigh,
            elevation: 3,
            shadowColor: colorScheme.shadow,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (final section in AppSection.values)
                    Expanded(
                      child: _NavigationDestination(
                        section: section,
                        selected: section.index == _selectedIndex,
                        onTap: () => _selectSection(section),
                        onLongPressStart: (details) =>
                            _beginQuickActions(section, details.globalPosition),
                        onLongPressMoveUpdate: (details) =>
                            _updateHoveredAction(details.globalPosition),
                        onLongPressEnd: (details) => _finishQuickActions(),
                        onLongPressCancel: _handleLongPressCancel,
                        onVerticalDragUpdate: (details) => _handleVerticalDrag(
                          section,
                          details.globalPosition,
                          details.primaryDelta ?? 0,
                        ),
                        onVerticalDragEnd: (details) {
                          if (_quickMenuDragActive) _finishQuickActions();
                        },
                        onVerticalDragCancel: _closeQuickActions,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectSection(AppSection section) {
    if (section.index == _selectedIndex) {
      _openQuickActions(section);
      return;
    }
    setState(() {
      _selectedIndex = section.index;
      _isNavigationBarVisible = true;
    });
    _syncSearchQuery(section);
  }

  void _openSettings() {
    _closeQuickActions();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  void _openQuickActions(AppSection section) {
    setState(() {
      _quickMenuSection = section;
      _quickActions = _actionsFor(section);
      _quickActionKeys = List.generate(
        _quickActions.length,
        (_) => GlobalKey(),
      );
      _hoveredActionIndex = null;
      _quickMenuDragActive = false;
    });
  }

  void _beginQuickActions(AppSection section, Offset globalPosition) {
    setState(() {
      _selectedIndex = section.index;
      _isNavigationBarVisible = true;
      _quickMenuSection = section;
      _quickActions = _actionsFor(section);
      _quickActionKeys = List.generate(
        _quickActions.length,
        (_) => GlobalKey(),
      );
      _hoveredActionIndex = null;
      _quickMenuDragActive = true;
    });
    _syncSearchQuery(section);
    _updateHoveredAction(globalPosition);
  }

  void _openSearch(){
    _closeQuickActions();
    final query=ref.read(searchQueryProvider(_selectedSection));
    _searchController.value=TextEditingValue(text:query,selection:TextSelection.collapsed(offset:query.length));
    setState(()=>_isSearchOpen=true);
    WidgetsBinding.instance.addPostFrameCallback((_)=>_searchFocusNode.requestFocus());
  }

  void _closeSearch(){
    ref.read(searchQueryProvider(_selectedSection).notifier).clear();
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(()=>_isSearchOpen=false);
  }

  void _syncSearchQuery(AppSection section){
    if(!_isSearchOpen)return;
    final query=ref.read(searchQueryProvider(section));
    _searchController.value=TextEditingValue(text:query,selection:TextSelection.collapsed(offset:query.length));
  }

  void _handleVerticalDrag(
    AppSection section,
    Offset globalPosition,
    double primaryDelta,
  ) {
    if (!_quickMenuDragActive) {
      if (primaryDelta < 0) {
        _beginQuickActions(section, globalPosition);
      }
      return;
    }
    _updateHoveredAction(globalPosition);
  }

  void _handleLongPressCancel() {
    if (!_quickMenuDragActive) _closeQuickActions();
  }

  void _updateHoveredAction(Offset globalPosition) {
    if (!_quickMenuDragActive) return;
    int? nextHoveredIndex;
    for (var index = 0; index < _quickActionKeys.length; index++) {
      final renderObject = _quickActionKeys[index].currentContext
          ?.findRenderObject();
      if (renderObject is! RenderBox) continue;
      final localPosition = renderObject.globalToLocal(globalPosition);
      if ((Offset.zero & renderObject.size).contains(localPosition)) {
        nextHoveredIndex = index;
        break;
      }
    }
    if (nextHoveredIndex != _hoveredActionIndex && mounted) {
      setState(() => _hoveredActionIndex = nextHoveredIndex);
    }
  }

  void _finishQuickActions() {
    if (_hoveredActionIndex != null) {
      _selectQuickAction(_hoveredActionIndex!);
    } else {
      _closeQuickActions();
    }
  }

  void _selectQuickAction(int index) {
    final section = _quickMenuSection;
    _closeQuickActions();
    if(section == AppSection.notes && index == 0){
      Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const NoteEditorPage()));
    }
  }

  void _closeQuickActions() {
    if (!mounted) return;
    setState(() {
      _quickMenuSection = null;
      _quickActions = const [];
      _quickActionKeys = const [];
      _hoveredActionIndex = null;
      _quickMenuDragActive = false;
    });
  }

  List<QuickAction> _actionsFor(AppSection section) => switch (section) {
    AppSection.calendar => const [
      QuickAction(
        label: 'Create event',
        description: 'Add something to your calendar.',
        icon: Icons.event_outlined,
      ),
      QuickAction(
        label: 'Plan a day',
        description: 'Set up a focused plan.',
        icon: Icons.today_outlined,
      ),
    ],
    AppSection.notes => const [
      QuickAction(
        label: 'Create note',
        description: 'Start writing something new.',
        icon: Icons.note_add_outlined,
      ),
      QuickAction(
        label: 'Create list',
        description: 'Turn an idea into a checklist.',
        icon: Icons.playlist_add,
      ),
    ],
    AppSection.people => const [
      QuickAction(
        label: 'Add person',
        description: 'Save someone important to you.',
        icon: Icons.person_add_alt_1,
      ),
      QuickAction(
        label: 'Log interaction',
        description: 'Remember a recent conversation.',
        icon: Icons.forum_outlined,
      ),
    ],
  };
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.section,
    required this.selected,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    required this.onVerticalDragCancel,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  final GestureLongPressEndCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final VoidCallback onVerticalDragCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: 'Open ${section.title} actions',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: onLongPressStart,
        onLongPressMoveUpdate: onLongPressMoveUpdate,
        onLongPressEnd: onLongPressEnd,
        onLongPressCancel: onLongPressCancel,
        onVerticalDragUpdate: onVerticalDragUpdate,
        onVerticalDragEnd: onVerticalDragEnd,
        onVerticalDragCancel: onVerticalDragCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? section.selectedIcon : section.icon,
                  color: foregroundColor,
                ),
                const SizedBox(height: 2),
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionMenu extends StatelessWidget {
  const _QuickActionMenu({
    required this.section,
    required this.actions,
    required this.actionKeys,
    required this.hoveredActionIndex,
    required this.onActionTap,
  });

  final AppSection section;
  final List<QuickAction> actions;
  final List<GlobalKey> actionKeys;
  final int? hoveredActionIndex;
  final ValueChanged<int> onActionTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 8,
      shadowColor: colorScheme.shadow,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            for (var index = 0; index < actions.length; index++)
              Expanded(
                child: _QuickActionTile(
                  key: actionKeys[index],
                  action: actions[index],
                  selected: hoveredActionIndex == index,
                  onTap: () => onActionTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final QuickAction action;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: foregroundColor),
            const SizedBox(height: 6),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
