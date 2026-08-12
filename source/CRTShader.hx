package;

import flixel.system.FlxAssets.FlxShader;

class CRTShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    void main()
    {
        vec2 uv = openfl_TextureCoordv;

        // CRT curvature
        vec2 curvedUV = uv * 2.0 - 1.0;

        curvedUV *= 1.0 + 0.08 * vec2(
            curvedUV.y * curvedUV.y,
            curvedUV.x * curvedUV.x
        );

        uv = curvedUV * 0.5 + 0.5;

        // Blacken the area outside the curved screen
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
        {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }

        // Get the screen color
        vec4 color = flixel_texture2D(bitmap, uv);

        // Scanlines
        float scanline = sin(uv.y * 800.0) * 0.08;
        color.rgb -= scanline;

        // Vignette
        vec2 vignetteUV = uv * 2.0 - 1.0;

        float vignette = 1.0 -
            dot(vignetteUV, vignetteUV) * 0.15;

        color.rgb *= vignette;

        gl_FragColor = color;
    }
    ')

    public function new()
    {
        super();
    }
}