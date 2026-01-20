import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget optimizado para mostrar imágenes de Pokémon con caché
class CachedPokemonImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedPokemonImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      placeholder: (context, url) => placeholder ?? 
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ??
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
          size: width != null ? width! * 0.5 : 24,
        ),
      // Configuración de caché
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      maxWidthDiskCache: 500,
      maxHeightDiskCache: 500,
    );
  }
}
