Shader "Hidden/Transitions"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}


		//customs
		_GradientTex("Gradient", 2D) = "white" {}
		_CutOff ("Cut off", Range(0,1)) = 0

		//fade
		_Fade ("Fade", Range(0,1)) = 0
		_FadeColor ("Fade Color", Color) = (1,1,1,1)
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
			sampler2D _GradientTex;
			float _CutOff;

			float _Fade;
			fixed4 _FadeColor;

			fixed4 cut_off_frag(v2f i)
			{
				fixed4 grad = tex2D(_GradientTex, i.uv);
				if (grad.r < _CutOff)
					return fixed4(0, 0, 0, 0);
					
				return tex2D(_MainTex, i.uv);
			}
			fixed4 fade_frag(v2f i)
			{
				fixed4 baseColor = tex2D(_MainTex, i.uv);
				return lerp(baseColor, _FadeColor, _Fade);
			}
			fixed4 offset_sample_frag(v2f i)
			{
				//red and green channels store the direction of the offset sample
				//blue channel stores the amount of the cut off
				
				fixed4 offsetTex = tex2D(_GradientTex, i.uv);
				
				fixed2 direction = fixed2(0, 0);
				direction.x = offsetTex.r == 0 ? 1 : -1;
				direction.y = offsetTex.g == 0 ? 1 : -1;

				if (offsetTex.b < _CutOff)
					return fixed4(0, 0, 0, 0);

				return tex2D(_MainTex, i.uv + (_CutOff * direction));
			}
			fixed4 mixed_frag(v2f i)
			{
				fixed4 grad = tex2D(_GradientTex, i.uv);
				if (grad.r < _CutOff)
					return fixed4(0, 0, 0, 0);

				fixed4 baseColor = tex2D(_MainTex, i.uv);
				return lerp(baseColor, _FadeColor, _Fade);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//return mixed_frag(i);
				return offset_sample_frag(i);	//offset 
				//return fade_frag(i);	//simple fade
				//return cut_off_frag(i);	//simple gradient
			}
			ENDCG
		}
	}
}
