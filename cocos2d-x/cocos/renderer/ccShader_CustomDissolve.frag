/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Brian Chapados
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

const char* ccCustomDissolve_frag = STRINGIFY(

\n#ifdef GL_ES\n
precision lowp float;
\n#endif\n

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_position;

uniform vec2 u_winSize;
uniform float u_speed;
uniform float u_time;
uniform sampler2D u_dissolveTexture;

const vec4 lineColor = vec4(155.0 / 255.0, 126.0 / 255.0, 160.0 / 255.0, 1.0);
const vec4 clear = vec4(0.0, 0.0, 0.0, 0.0);
const float lineWidth = 0.1;

void main()
{
    vec4 color = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);

    vec2 dissolveTexCoord;
    dissolveTexCoord.x = (v_position.x / u_winSize.x);
    dissolveTexCoord.y = (v_position.y / u_winSize.y);

    vec4 dissolve = texture2D(u_dissolveTexture, dissolveTexCoord);

    float offset = u_time * u_speed;

    float dissolveVal = 1.2 - offset;
    if (dissolveVal < -0.2)
    {
        dissolveVal = -0.2;
    }

    //float factor = dissolve.r;
    float factor = 1.0 - dissolve.r;

    float isClear = float(int(factor - (dissolveVal + lineWidth) + 0.99));
    float isAtLeastLine = float(int(factor - dissolveVal + 0.99));

    vec4 altCol = mix(lineColor, clear, isClear);

    vec3 albedo = mix(color.rgb, altCol.rgb, isAtLeastLine);
    float alpha = mix(color.a, 0.0, isClear);

    gl_FragColor = vec4(albedo, alpha);
}

);
