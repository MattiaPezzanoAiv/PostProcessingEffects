﻿Shader "Hidden/Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogOffset ("Fog Offset", Range(-1,1)) = 0
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
			fixed4 _FogColor;
			fixed _FogOffset;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv)).r;

				col = lerp(col, _FogColor, depth + _FogOffset);
			
				return col;
			}
			ENDCG
		}
	}
}
