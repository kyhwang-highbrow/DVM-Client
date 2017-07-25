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
		float rate = 2.0;
		
		if (color.r > 0.25)	color.r = (color.r + 0.25) / rate;
		else				color.r = (color.r) / rate;
		
							color.g = (color.g) / rate;
		
		if (color.b > 0.25)	color.b = (color.b + 0.25) / rate;
		else				color.b = (color.b) / rate;
				
		result = vec4(color.r, color.g, color.b, alpha);
	}

    gl_FragColor = vec4(result.r, result.g, result.b, alpha);
}