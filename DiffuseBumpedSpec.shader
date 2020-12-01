Shader "Darkcom/Triplanar Projection/World/DiffuseBumpedSpec" {
	Properties {
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.01, 1)) = 0.078125
		_Blend("Blending", Range (0.01, 0.4)) = 0.2

		[MaterialToggle(IF_SNOW)] _IfSnow("if Snow", Float) = 1
		[ShowIf(IF_SNOW)]_Snow("Snow Level", Range(0,1)) = 1
		[ShowIf(IF_SNOW)]_SnowDirection("Snow Direction", Vector) = (0,1,0)
		[ShowIf(IF_SNOW)]_SnowDepth("Snow Depth", Range(0,0.2)) = 0.1
		[ShowIf(IF_SNOW)]_Wetness("Wetness", Range(0, 0.5)) = 0.3
		[ShowIf(IF_SNOW)]_SnowLevel("Snow level", Float) = 1
	}


	SubShader {
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 400
		
		CGPROGRAM
		#pragma surface surf BlinnPhong vertex:vert
		#pragma shader_feature IF_SNOW
		#include "TriplanarCustom.cginc"
		#pragma target 3.0

		sampler2D _MainTex, _BumpMap;
		float4 _MainTex_ST, _BumpMap_ST;
		half _Shininess;
		fixed _Blend;

#if IF_SNOW
		float _Snow, _SnowDepth, _Wetness;
		float4 _SnowDirection;
		float _SnowLevel;
#endif

		struct Input {
			float3 weight : TEXCOORD0;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			
			o.weight = TriplanarWeight(v.normal, _Blend);
		}
		
		void surf(Input IN, inout SurfaceOutput o) {
			//Unity 5 texture interpolators already fill in limits, and no room for packing
			//So we do the uvs per pixel :(
			
			fixed4 col = GetTriplanarProjection(_MainTex, IN.worldPos, _MainTex_ST, IN.weight);
#if IF_SNOW
			half3 worldNormal = WorldNormalVector(IN, o.Normal);
			o.Albedo = SnowProjection(worldNormal, _SnowDirection, _Snow, _Wetness, IN.worldPos, _SnowLevel, col.rgb);
#else
			o.Albedo = col.rgb;
#endif
			o.Gloss = col.a;
			o.Specular = _Shininess;
			
			o.Normal = abs(GetTriplanarNormal(_BumpMap, IN.worldPos, _BumpMap_ST, IN.weight));
			o.Alpha = col.a;
		}
		ENDCG
	}

	FallBack "Legacy Shaders/Bumped Specular"
}