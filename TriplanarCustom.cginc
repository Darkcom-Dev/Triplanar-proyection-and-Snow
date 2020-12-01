
#ifndef TRIPLANAR_CUSTOM_CGINC_INCLUDED
#define TRIPLANAR_CUSTOM_CGINC_INCLUDED

fixed3 TriplanarWeight(fixed3 normal, fixed blend) {
	fixed3 n = max(abs(normal) - blend, 0);
	return n / (n.x + n.y + n.z).x;
}

fixed3 SnowProjection(fixed3 worldNormal ,fixed3 windDirection, fixed amount, fixed wetness, fixed3 worldPos, fixed snowLevel, fixed3 color) {
	half difference = dot(worldNormal, windDirection.xyz) - lerp(1, -1, amount);
	difference = saturate(difference / wetness);
	fixed _worldPos = dot(worldPos, fixed3(0, 1 / snowLevel, 0));
	return lerp(color, difference + (1 - difference) * color, _worldPos);
}

float4 GetTriplanarProjection(sampler2D mainTex, fixed3 worldPos, fixed4 mainTex_ST, fixed3 weight) {
	fixed2 uvx = (worldPos.yz - mainTex_ST.zw) * mainTex_ST.xy;
	fixed2 uvy = (worldPos.xz - mainTex_ST.zw) * mainTex_ST.xy;
	fixed2 uvz = (worldPos.xy - mainTex_ST.zw) * mainTex_ST.xy;
	fixed4 cz = tex2D(mainTex, uvx) * weight.x;
	fixed4 cy = tex2D(mainTex, uvy) * weight.y;
	fixed4 cx = tex2D(mainTex, uvz) * weight.z;
	return (cz + cy + cx);
}

float3 GetTriplanarNormal(sampler2D bumpMap, fixed3 worldPos, fixed4 bumpMap_ST, fixed3 weight) {
	fixed2 uvx = (worldPos.yz - bumpMap_ST.zw) * bumpMap_ST.xy;
	fixed2 uvy = (worldPos.xz - bumpMap_ST.zw) * bumpMap_ST.xy;
	fixed2 uvz = (worldPos.xy - bumpMap_ST.zw) * bumpMap_ST.xy;
	fixed3 bz = UnpackNormal(tex2D(bumpMap, uvx)) * weight.x;
	fixed3 by = UnpackNormal(tex2D(bumpMap, uvy)) * weight.y;
	fixed3 bx = UnpackNormal(tex2D(bumpMap, uvz)) * weight.z;
	return abs(normalize(bz + by + bx));
}

#endif // TERRAIN_SPLATMAP_COMMON_CGINC_INCLUDED