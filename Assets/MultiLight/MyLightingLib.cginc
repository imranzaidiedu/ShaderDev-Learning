#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define TAU 6.2831855

struct MeshData
{
    float4 vertex : POSITION;
    float3 normals : NORMAL;
    float4 tangent : TANGENT;//xyz = tangent direction, w = tangent sign
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float4 vertex : SV_POSITION;
    float3 wPos : TEXCOORD2;
    float3 tangent : TEXCOORD3;
    float3 bitangent : TEXCOORD4;
    LIGHTING_COORDS(5, 6)
    //^5 and 6 is referring to TEXCOORD5 and TEXCOORD6 respectively
};

sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;
sampler2D _RockNormals;
sampler2D _RockHeight;
sampler2D _DiffuseIBL;
float _Gloss;
float4 _Color;
float4 _AmbientLight;
float _NormalIntensity;
float _DisplacementStrength;

float2 DirToRectilinear(float3 dir)
{
    float x = atan2(dir.z, dir.x);
    x = x / TAU;
    x = x + 0.5;

    float y = dir.y;
    y = y * 0.5 + 0.5;

    return float2(x, y);
}

float2 Rotate(float2 v, float angleRad)
{
    float ca = cos(angleRad);
    float sa = sin(angleRad);
    return float2(ca * v.x - sa * v.y, sa * v.x + ca * v.y);
}

Interpolators vert (MeshData v)
{
    Interpolators o;

    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    //o.uv = Rotate(o.uv - 0.5, _Time.y * 0.2) + 0.5;
    
    float height = tex2Dlod(_RockHeight, float4(o.uv, 0, 0)).x * 2 - 1;
    
    v.vertex.xyz += v.normals * (height * _DisplacementStrength);
    
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    o.normal = UnityObjectToWorldNormal(v.normals);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent);
    o.bitangent *= v.tangent.w * unity_WorldTransformParams.w; //correctly handle flipping/mirroring

    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

fixed4 frag (Interpolators i) : SV_Target
{
    float3 rock = tex2D(_RockAlbedo, i.uv);

    float3 surfaceColor = rock * _Color.rgb;
    float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormals, i.uv));
    tangentSpaceNormal = lerp(float3(0,0,1), tangentSpaceNormal, _NormalIntensity);

    float3x3 mtxTangToWorld = {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z
    };

    float3 N = mul(mtxTangToWorld, tangentSpaceNormal);
    //float3 N = normalize(i.normal);

    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i);
    float3 lambert = saturate(dot(N,L));
    float3 diffusionLight = (lambert  * attenuation) * _LightColor0.xyz;

    float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(N), 0, 0)).xyz;
    diffusionLight += diffuseIBL;
    
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize(L + V);
                
    float3 specularLight = saturate(dot(H, N)) * (lambert > 0);

    float specularExponent = exp2(_Gloss * 11) + 2;
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation;
    specularLight *= _LightColor0.xyz;
                
    return float4(diffusionLight * surfaceColor + specularLight, 1);
}