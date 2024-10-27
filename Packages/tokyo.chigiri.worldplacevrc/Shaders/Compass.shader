Shader "Chigiri/WorldPlace.VRC/Compass"
{
    Properties
    {
        _Color ("Foreground Color", Color) = (0, 0, 0, 1)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            fixed4 _BackgroundColor;

            #define MARGIN 0.05
            #define DIGITS 6
            #define ROWS 3

            static const float powerOfTen[] = {
                1,
                10,
                100,
                1000,
                10000,
                100000,
                1000000,
                10000000,
                100000000,
                1000000000,
                10000000000
            };

            #define FONT_SIZE int2(6, 8)
            #define DOTS(v) (((v)&1) | ((v)>>4&1)<<1 | ((v)>>8&1)<<2 | ((v)>>12&1)<<3 | ((v)>>16&1)<<4 | ((v)>>20&1)<<5)

            static const uint font[] = {
                0,
                // 0
                DOTS(0x011100),
                DOTS(0x100010),
                DOTS(0x100010),
                DOTS(0x100010),
                DOTS(0x011100), 0,0,0,
                // 1
                DOTS(0x011000),
                DOTS(0x001000),
                DOTS(0x001000),
                DOTS(0x001000),
                DOTS(0x001000), 0,0,0,
                // 2
                DOTS(0x111100),
                DOTS(0x000010),
                DOTS(0x011100),
                DOTS(0x100000),
                DOTS(0x111110), 0,0,0,
                // 3
                DOTS(0x111100),
                DOTS(0x000010),
                DOTS(0x011100),
                DOTS(0x000010),
                DOTS(0x111100), 0,0,0,
                // 4
                DOTS(0x100100),
                DOTS(0x100100),
                DOTS(0x100100),
                DOTS(0x111110),
                DOTS(0x000100), 0,0,0,
                // 5
                DOTS(0x111110),
                DOTS(0x100000),
                DOTS(0x111100),
                DOTS(0x000010),
                DOTS(0x111100), 0,0,0,
                // 6
                DOTS(0x011100),
                DOTS(0x100000),
                DOTS(0x111100),
                DOTS(0x100010),
                DOTS(0x011100), 0,0,0,
                // 7
                DOTS(0x111110),
                DOTS(0x000010),
                DOTS(0x000100),
                DOTS(0x001000),
                DOTS(0x001000), 0,0,0,
                // 8
                DOTS(0x011100),
                DOTS(0x100010),
                DOTS(0x011100),
                DOTS(0x100010),
                DOTS(0x011100), 0,0,0,
                // 9
                DOTS(0x011100),
                DOTS(0x100010),
                DOTS(0x011110),
                DOTS(0x000010),
                DOTS(0x011100), 0,0,0,
                // -
                DOTS(0x000000),
                DOTS(0x000000),
                DOTS(0x011100),
                DOTS(0x000000),
                DOTS(0x000000), 0,0,0,
                // +
                DOTS(0x000000),
                DOTS(0x001000),
                DOTS(0x011100),
                DOTS(0x001000),
                DOTS(0x000000), 0,0,0,
                // .
                DOTS(0x000000),
                DOTS(0x000000),
                DOTS(0x000000),
                DOTS(0x000000),
                DOTS(0x001000), 0,0,0,
                // X
                DOTS(0x100010),
                DOTS(0x010100),
                DOTS(0x001000),
                DOTS(0x010100),
                DOTS(0x100010), 0,0,0,
                // Y
                DOTS(0x100010),
                DOTS(0x100010),
                DOTS(0x011100),
                DOTS(0x001000),
                DOTS(0x001000), 0,0,0,
                // Z
                DOTS(0x111110),
                DOTS(0x000100),
                DOTS(0x001000),
                DOTS(0x010000),
                DOTS(0x111110), 0,0,0,
            };
            #define FONT_NUM_MINUS 10
            #define FONT_NUM_PLUS  11
            #define FONT_NUM_DOT   12
            static const uint fontNumXYZ[] = { 13, 14, 15 };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float renderNumber(int c, float2 xy)
            {
                int2 cr = floor(xy * FONT_SIZE);
                uint dots = font[c * FONT_SIZE.y + cr.y];
                return dots >> (FONT_SIZE.x - 1 - cr.x) & 1;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 wp = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                wp = clamp(round(wp * 1000.0), -9999999, 9999999);
                float2 uv = float2(i.uv.x, 1.0 - i.uv.y);
                uv = uv / (1.0 - MARGIN * 2) - MARGIN;
                float2 crFloat = uv * float2(DIGITS+3, ROWS);
                int2 crInt = floor(crFloat);
                float2 crFrac = crFloat - crInt;

                float4 a = float4(0.25, 0.5, 0.75, 1);
                float value = wp[crInt.y];
                float dot;
                if (min(uv.x, uv.y) < 0 || 1 < max(uv.x, uv.y))
                {
                    dot = 0;
                }
                else if (crInt.x == 0)
                {
                    dot = renderNumber(fontNumXYZ[crInt.y], crFrac);
                }
                else if (crInt.x == 1)
                {
                    dot = value == 0 ? 0 : renderNumber(value < 0 ? FONT_NUM_MINUS : FONT_NUM_PLUS, crFrac);
                }
                else if (crInt.x == 5)
                {
                    dot = renderNumber(FONT_NUM_DOT, crFrac);
                }
                else
                {
                    int digit = crInt.x - (crInt.x < 5 ? 2 : 3);
                    float number = abs(value / powerOfTen[DIGITS-1-digit]) % 10;
                    int numberFix = round(floor(number+.01));
                    dot = renderNumber(numberFix, crFrac);
                }
                fixed4 color = lerp(_BackgroundColor, _Color, dot);
                return color;
            }
            ENDCG
        }
    }
}
