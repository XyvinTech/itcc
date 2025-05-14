import 'package:flutter/material.dart';

class SearchableDropDown extends StatefulWidget {
  final String? hintText;
  final String? label;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final String searchHintText;

  const SearchableDropDown({
    this.label,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    Key? key,
    this.hintText,
    this.searchHintText = 'Search...',
  }) : super(key: key);

  @override
  _SearchableDropDownState createState() => _SearchableDropDownState();
}

class _SearchableDropDownState extends State<SearchableDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isDropdownOpen = false;
  List<DropdownMenuItem<String>> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    _filteredItems = List.from(widget.items);
    _selectedValue = widget.value;
  }
  
  // Track search field focus state
  bool _searchHasFocus = false;

  @override
  void dispose() {
    _closeDropdown();
    _animationController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (_isDropdownOpen) return;
    
    _isDropdownOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
      _searchController.clear();
      setState(() {
        _filteredItems = List.from(widget.items);
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => (item.child as Text).data!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _selectItem(DropdownMenuItem<String> item) {
    setState(() {
      _selectedValue = item.value;
    });
    widget.onChanged(item.value);
    _searchHasFocus = false;
    _closeDropdown();
    _focusNode.unfocus();
  }

  String? _getDisplayText() {
    if (_selectedValue == null) return null;
    
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == _selectedValue,
      orElse: () => const DropdownMenuItem(value: '', child: Text('')),
    );
    
    return selectedItem.value == '' ? null : (selectedItem.child as Text).data;
  }

OverlayEntry _createOverlayEntry() {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final size = renderBox.size;

  return OverlayEntry(
    builder: (context) => Positioned(
      width: size.width,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0.0, size.height + 5.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            constraints: BoxConstraints(
              maxHeight: 300,
              minWidth: size.width,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: widget.searchHintText,
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF718096)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3182CE), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                    ),
                    onChanged: _filterItems,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.value == _selectedValue;

                      return InkWell(
                        onTap: () => _selectItem(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: isSelected ? const Color(0xFFEBF8FF) : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? const Color(0xFF3182CE)
                                        : const Color(0xFF2D3748),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  child: item.child,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF3182CE),
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.label ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!_isDropdownOpen) {
                    _focusNode.requestFocus();
                    _openDropdown();
                  } else {
                    _closeDropdown();
                    _focusNode.unfocus();
                  }
                },
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: FormField<String>(
                    validator: widget.validator,
                    initialValue: _selectedValue,
                    builder: (FormFieldState<String> state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isDropdownOpen
                                    ? const Color(0xFF3182CE)
                                    : state.hasError
                                        ? Colors.red
                                        : const Color(0xFFE2E8F0),
                                width: _isDropdownOpen ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      _getDisplayText() ?? widget.hintText ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selectedValue == null
                                            ? const Color(0xFF718096)
                                            : const Color(0xFF2D3748),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    _isDropdownOpen
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: const Color(0xFF718096),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}