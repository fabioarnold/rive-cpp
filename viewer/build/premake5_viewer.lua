workspace 'rive'
configurations {
    'debug',
    'release'
}

dependencies = os.getenv('DEPENDENCIES')

rive = '../../'
rive_thirdparty = '../../../../third_party'
rive_tess = '../../tess'
rive_skia = '../../skia'
skia = dependencies .. '/skia'
libpng = dependencies .. '/libpng'

if _OPTIONS.renderer == 'tess' then
    dofile('premake5_libpng.lua')
end

project 'rive_viewer'
do
    if _OPTIONS.renderer == 'tess' then
        dependson 'libpng'
    end
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    targetdir('%{cfg.system}/bin/%{cfg.buildcfg}/' .. _OPTIONS.renderer .. '/' .. _OPTIONS.graphics)
    objdir('%{cfg.system}/obj/%{cfg.buildcfg}/' .. _OPTIONS.renderer .. '/' .. _OPTIONS.graphics)

    defines { "RIVE_TEXT" }

    includedirs {
        '../include',
        rive .. '/include',
        rive .. '/skia/renderer/include',  -- for renderfont backends
        rive_thirdparty .. '/externals/harfbuzz/src',
        dependencies,
        dependencies .. '/sokol',
        dependencies .. '/imgui'
    }

    links {
        'rive',
        'rive_harfbuzz',
    }

    libdirs {
        rive .. '/build/%{cfg.system}/bin/%{cfg.buildcfg}',
        rive_thirdparty .. '/harfbuzz/build/%{cfg.buildcfg}/bin',
    }

    files {
        '../src/**.cpp',
        '../../utils/rive_utf.cpp',
        rive .. '/skia/renderer/src/renderfont_coretext.cpp',
        rive .. '/skia/renderer/src/renderfont_hb.cpp',
        rive .. '/utils/rive_utf.cpp',
        dependencies .. '/imgui/imgui.cpp',
        dependencies .. '/imgui/imgui_widgets.cpp',
        dependencies .. '/imgui/imgui_tables.cpp',
        dependencies .. '/imgui/imgui_draw.cpp'
    }

    buildoptions {
        '-Wall',
        '-fno-exceptions',
        '-fno-rtti'
    }

    filter {
        'system:macosx'
    }
    do
        links {
            'Cocoa.framework',
            'IOKit.framework',
            'CoreVideo.framework',
            'OpenGL.framework'
        }
        files {
            '../src/**.m',
            '../src/**.mm'
        }
    end

    filter {
        'system:macosx',
        'options:graphics=gl'
    }
    do
        links {
            'OpenGL.framework'
        }
    end

    filter {
        'system:macosx',
        'options:graphics=metal'
    }
    do
        links {
            'Metal.framework',
            'MetalKit.framework',
            'QuartzCore.framework'
        }
    end

    -- Tess Renderer Configuration
    filter {
        'options:renderer=tess'
    }
    do
        includedirs {
            rive_tess .. '/include',
            libpng
        }
        defines {
            'RIVE_RENDERER_TESS'
        }
        links {
            'rive_tess_renderer',
            'libpng',
            'zlib'
        }
        libdirs {
            rive_tess .. '/build/%{cfg.system}/bin/%{cfg.buildcfg}'
        }
    end

    filter {
        'options:renderer=tess',
        'options:graphics=gl'
    }
    do
        defines {
            'SOKOL_GLCORE33'
        }
    end

    filter {
        'options:renderer=tess',
        'options:graphics=metal'
    }
    do
        defines {
            'SOKOL_METAL'
        }
    end

    filter {
        'options:renderer=tess',
        'options:graphics=d3d'
    }
    do
        defines {
            'SOKOL_D3D11'
        }
    end

    filter {
        'options:renderer=skia',
        'options:graphics=gl'
    }
    do
        defines {
            'SK_GL',
            'SOKOL_GLCORE33'
        }
        files {
            '../src/skia/viewer_skia_gl.cpp'
        }
        libdirs {
            skia .. '/out/gl/%{cfg.buildcfg}'
        }
    end

    filter {
        'options:renderer=skia',
        'options:graphics=metal'
    }
    do
        defines {
            'SK_METAL',
            'SOKOL_METAL'
        }
        libdirs {
            skia .. '/out/metal/%{cfg.buildcfg}'
        }
    end

    filter {
        'options:renderer=skia',
        'options:graphics=d3d'
    }
    do
        defines {
            'SK_DIRECT3D'
        }
        libdirs {
            skia .. '/out/d3d/%{cfg.buildcfg}'
        }
    end

    filter {
        'options:renderer=skia'
    }
    do
        includedirs {
            skia,
            skia .. '/include/core',
            skia .. '/include/effects',
            skia .. '/include/gpu',
            skia .. '/include/config',
        }
        defines {
            'RIVE_RENDERER_SKIA'
        }
        libdirs {
            rive_skia .. '/renderer/build/%{cfg.system}/bin/%{cfg.buildcfg}',
            rive_thirdparty .. '/harfbuzz/build/%{cfg.buildcfg}/bin'
        }
        links {
            'skia',
            'rive_skia_renderer',
        }
    end

    filter 'configurations:debug'
    do
        buildoptions {
            '-g'
        }
        defines {
            'DEBUG'
        }
        symbols 'On'
    end

    filter 'configurations:release'
    do
        buildoptions {
            '-flto=full'
        }
        defines {
            'RELEASE'
        }
        defines {
            'NDEBUG'
        }
        optimize 'On'
    end

    -- CLI config options
    newoption {
        trigger = 'graphics',
        value = 'gl',
        description = 'The graphics api to use.',
        allowed = {
            {
                'gl'
            },
            {
                'metal'
            },
            {
                'd3d'
            }
        }
    }

    newoption {
        trigger = 'renderer',
        value = 'skia',
        description = 'The renderer to use.',
        allowed = {
            {
                'skia'
            },
            {
                'tess'
            }
        }
    }
end