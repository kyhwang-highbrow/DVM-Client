#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 color = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
	vec4 result = vec4(0.0, 0.0, 0.0, 0.0);
	float alpha = color.a;
	
	if (alpha > 0.0)
	{
		color.r = color.r + ((0.0 - color.r) * 0.5);
		color.g = color.g + ((0.0 - color.g) * 0.5);
		color.b = color.b + ((1.0 - color.b) * 0.6);
		
		result = vec4(color.r, color.g, color.b, alpha);
	}

    gl_FragColor = vec4(result.r, result.g, result.b, alpha);
}