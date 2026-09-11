import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/business.dart';
import '../../models/business_image.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/error_banner.dart';

class BusinessPhotosScreen extends StatefulWidget {
  final Business business;
  const BusinessPhotosScreen({super.key, required this.business});

  @override
  State<BusinessPhotosScreen> createState() => _BusinessPhotosScreenState();
}

class _BusinessPhotosScreenState extends State<BusinessPhotosScreen> {
  static const int maxImages = 5;
  final _picker = ImagePicker();

  late String? _logoUrl;
  late List<BusinessImage> _images;

  bool _isLogoUploading = false;
  bool _isImageUploading = false;
  String? _deletingImageId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _logoUrl = widget.business.logoUrl;
    _images = List.of(widget.business.images);
  }

  Future<void> _pickAndUploadLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _isLogoUploading = true;
      _errorMessage = null;
    });

    final provider = context.read<BusinessProvider>();
    final updated = await provider.uploadLogo(widget.business.id, picked);

    if (!mounted) return;
    setState(() {
      _isLogoUploading = false;
      if (updated != null) {
        _logoUrl = updated.logoUrl;
      } else {
        _errorMessage = provider.errorMessage ?? 'Failed to upload logo.';
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    if (_images.length >= maxImages) return;

    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _isImageUploading = true;
      _errorMessage = null;
    });

    final provider = context.read<BusinessProvider>();
    final newImage = await provider.addBusinessImage(widget.business.id, picked);

    if (!mounted) return;
    setState(() {
      _isImageUploading = false;
      if (newImage != null) {
        _images = [..._images, newImage];
      } else {
        _errorMessage = provider.errorMessage ?? 'Failed to add photo.';
      }
    });
  }

  Future<void> _deleteImage(String imageId) async {
    setState(() {
      _deletingImageId = imageId;
      _errorMessage = null;
    });

    final provider = context.read<BusinessProvider>();
    final success = await provider.deleteBusinessImage(widget.business.id, imageId);

    if (!mounted) return;
    setState(() {
      _deletingImageId = null;
      if (success) {
        _images.removeWhere((img) => img.id == imageId);
      } else {
        _errorMessage = provider.errorMessage ?? 'Failed to delete photo.';
      }
    });
  }

  Future<ImageSource?> _showImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text('Add Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 8),
              ],
            ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Manage Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              const Text('Logo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Your business's main display image, shown across the app.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _isLogoUploading ? null : _pickAndUploadLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isLogoUploading
                        ? const Center(child: CircularProgressIndicator())
                        : _logoUrl == null || _logoUrl!.isEmpty
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                        const SizedBox(height: 6),
                        Text('Add logo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ],
                    )
                        : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(_logoUrl!, fit: BoxFit.cover),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${_images.length}/$maxImages', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Add photos of your space, work, or team - up to 5.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _images.length + (_images.length < maxImages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return GestureDetector(
                      onTap: _isImageUploading ? null : _pickAndUploadImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _isImageUploading
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.add, color: AppColors.primary),
                      ),
                    );
                  }

                  final image = _images[index];
                  final isDeleting = _deletingImageId == image.id;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(image.imageUrl, fit: BoxFit.cover)),
                      if (isDeleting)
                        Container(
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        )
                      else
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _deleteImage(image.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}