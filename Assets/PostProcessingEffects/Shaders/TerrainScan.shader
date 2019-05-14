Shader "Hidden/TerrainScan"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Value ("Value", Range(0,1)) = 0
		_Width ("Width", Float) = 0.05
		_EdgeWidth ("Edge Width", Range(0,0.05)) = 0
		_FarColor("Far Color", Color) = (1,1,1,1)
		_NearColor("Near Color", Color) = (1,1,1,1)
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_Offset("Offset", Range(-1,1)) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float _Value;
			float _Width;
			fixed4 _FarColor;
			fixed4 _NearColor;
			fixed4 _EdgeColor;
			fixed _Offset;
			fixed _EdgeWidth;

			fixed remap(fixed value, fixed oldMin, fixed oldMax, fixed newMin, fixed newMax)
			{
				return (value - oldMin) / (newMin - oldMin) * (newMax - oldMax) + oldMax;

			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col.rgb = 1 - col.rgb;
				fixed depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv)).r;

				if (depth <= _Value && depth >= (_Value - _Width) && depth < 1)
				{
					fixed delta = remap(depth.r, 0,1,_Value, (_Value - _Width));
					if (depth > _Value - _EdgeWidth)
						return _EdgeColor;
					fixed diff = (_Value - depth.r) / _Width;
					diff = 1 - diff;
					
					fixed4 lineCol = lerp(_NearColor, _FarColor, diff + _Offset);
					//return lerp(lineCol, col, 0.5);
					return col + diff * lineCol;
				}
				return col; 
			}
			
			ENDCG
		}
	}
}
