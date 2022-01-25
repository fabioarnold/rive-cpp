#!/bin/sh

set -e

./get_skia.sh

cd skia

# build static for host
gn gen out/static --type=static_library --args=" \
    extra_cflags=[\"-fno-rtti\", \"-flto=full\", \"-DSK_DISABLE_SKPICTURE\", \"-DSK_DISABLE_TEXT\", \"-DRIVE_OPTIMIZED\", \"-DSK_DISABLE_LEGACY_SHADERCONTEXT\", \"-DSK_DISABLE_LOWP_RASTER_PIPELINE\", \"-DSK_FORCE_RASTER_PIPELINE_BLITTER\", \"-DSK_DISABLE_AAA\", \"-DSK_DISABLE_EFFECT_DESERIALIZATION\"] \

    is_official_build=true \
    skia_use_gl=true \
    skia_use_zlib=true \
    skia_enable_gpu=true \
    skia_enable_fontmgr_empty=true \
    skia_use_libpng_encode=true \
    skia_use_libpng_decode=true \
    skia_enable_skgpu_v1=true \

    skia_use_dng_sdk=false \
    skia_use_egl=false \
    skia_use_expat=false \
    skia_use_fontconfig=false \
    skia_use_freetype=false \
    skia_use_icu=false \
    skia_use_libheif=false \
    skia_use_system_libpng=false \
    skia_use_libjpeg_turbo_encode=false \
    skia_use_libjpeg_turbo_decode=false \
    skia_use_libwebp_encode=false \
    skia_use_libwebp_decode=false \
    skia_use_lua=false \
    skia_use_piex=false \
    skia_use_vulkan=false \
    skia_use_metal=false \
    skia_use_angle=false \
    skia_use_system_zlib=false \
    skia_enable_spirv_validation=false \
    skia_enable_pdf=false \
    skia_enable_skottie=false \
    skia_enable_tools=false \
    skia_enable_skgpu_v2=false \
    "
ninja -C out/static
du -hs out/static/libskia.a

cd ..