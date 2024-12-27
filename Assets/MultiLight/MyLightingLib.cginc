float InverseLerp(float a, float b, float v)
{
    return (v-a)/(b-a);
}

#include "UnityCG.cginc"
            
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct MeshData
{
    float4 vertex : POSITION;
    float3 normals : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float4 vertex : SV_POSITION;
    float3 wPos : TEXCOORD2;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Gloss;
float4 _Color;

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normals);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    return o;
}

fixed4 frag (Interpolators i) : SV_Target
{
    float3 N = normalize(i.normal);

    float3 L = _WorldSpaceLightPos0.xyz;

    float3 lambert = saturate(dot(N,L));
    float3 diffusionLight = lambert * _LightColor0.xyz;
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize(L + V);
                
    float3 specularLight = saturate(dot(H, N)) * (lambert > 0);

    float specularExponent = exp2(_Gloss * 11) + 2;
    specularLight = pow(specularLight, specularExponent);
    specularLight *= _LightColor0.xyz;
                
    return float4(diffusionLight * _Color + specularLight, 1);
}