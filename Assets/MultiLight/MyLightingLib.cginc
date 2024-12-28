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
    LIGHTING_COORDS(3, 4)
    //^3 and 4 is referring to TEXCOORD3 and TEXCOORD4 respectively
};

sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;
float _Gloss;
float4 _Color;

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);
    o.normal = UnityObjectToWorldNormal(v.normals);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);

    TRANSFER_VERTEX_TO_FRAGMENT(o);
    
    return o;
}

fixed4 frag (Interpolators i) : SV_Target
{
    float3 rock = tex2D(_RockAlbedo, i.uv);

    float3 surfaceColor = rock * _Color.rgb;
    
    float3 N = normalize(i.normal);

    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i);
    float3 lambert = saturate(dot(N,L));
    float3 diffusionLight = (lambert  * attenuation) * _LightColor0.xyz;
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize(L + V);
                
    float3 specularLight = saturate(dot(H, N)) * (lambert > 0);

    float specularExponent = exp2(_Gloss * 11) + 2;
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation;
    specularLight *= _LightColor0.xyz;
                
    return float4(diffusionLight * surfaceColor + specularLight, 1);
}