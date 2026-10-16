import 'package:flutter/material.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/repositories/destination_repository.dart';
import 'package:waylo/repositories/destination_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final DestinationRepository _repository =
      DestinationRepositoryFactory.create();
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _overlayController =
      OverlayPortalController();

  late final TextEditingController _controller;
  late final bool _ownsController;

  List<Destination> _destinations = [];
  List<Destination> _results = [];
  double _width = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _loadDestinations();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    final result = await _repository.getAllDestinations();
    if (!mounted) return;
    setState(() => _destinations = result);
  }

  void _search(String value) {
    final keyword = value.trim().toLowerCase();

    setState(() {
      _results = keyword.isEmpty
          ? []
          : _destinations.where((destination) {
              final location = destination.location;
              return destination.name.toLowerCase().contains(keyword) ||
                  location.subdistrictName.toLowerCase().contains(keyword) ||
                  location.districtName.toLowerCase().contains(keyword) ||
                  location.provinceName.toLowerCase().contains(keyword);
            }).toList();
    });

    if (keyword.isEmpty) {
      _closeResults();
    } else if (!_overlayController.isShowing) {
      _overlayController.show();
    }

    widget.onChanged?.call(value);
  }

  void _closeResults() {
    if (_overlayController.isShowing) _overlayController.hide();
  }

  void _open(Destination destination) {
    _closeResults();
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detaildestination(destination: destination),
      ),
    );
  }

  Widget _buildResults() {
    return Material(
      color: AppColors.card,
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: _results.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Destinasi tidak ditemukan',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _results.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final destination = _results[index];
                  final location = destination.location;

                  return InkWell(
                    onTap: () => _open(destination),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destination.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${location.subdistrictName}, ${location.districtName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeResults,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: SizedBox(width: _width, child: _buildResults()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;

        return CompositedTransformTarget(
          link: _layerLink,
          child: OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: _buildOverlay,
            child: SizedBox(
              height: 54,
              child: Stack(
                children: [
                  // Kotak search
                  Positioned.fill(
                    child: TextField(
                      controller: _controller,
                      onChanged: _search,
                      onSubmitted: widget.onSubmitted,
                      onTap: widget.onTap,
                      readOnly: widget.readOnly,
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search destinations or countries',
                        hintStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 21,
                          color: AppColors.textSecondary,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 54,
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Inner shadow di bagian atas
                  Positioned(
                    top: 1,
                    left: 1,
                    right: 1,
                    height: 8,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}