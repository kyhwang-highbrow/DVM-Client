varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

cosnt float factor = 1.0;

const vec2 windowSize = vec2(100,100);

float Luminance( in vec4 color )
{
    return (color.r + color.g + color.b ) / 3.0;
}

vec4 Sepia( in vec4 color )
{
    return vec4(
          clamp(color.r * 0.393 + color.g * 0.769 + color.b * 0.189, 0.0, 1.0)
        , clamp(color.r * 0.349 + color.g * 0.686 + color.b * 0.168, 0.0, 1.0)
        , clamp(color.r * 0.272 + color.g * 0.534 + color.b * 0.131, 0.0, 1.0)
        , color.a
    );
}

void main (void){
  out_Color = texture2D(CC_Texture0, v_texCoord);
  out_Color = mix(out_Color, Sepia(out_Color), clamp(factor, 0.0, 1.0) );
}
