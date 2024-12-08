Shader "Unlit/FirstUnlitShaderPart2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc" 

            float4 _Color;
            
            struct MeshData 
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //Two statements below are doing the same thing as if you go in the definition of UnityObjectToWorldNormal, you will find the same
                //code we have impmelement on the line below
                o.normal = UnityObjectToWorldNormal(v.normals);

                
                //As we are projecting object to world, the below logic can be a little confusing as its saying worldToObject which is opposite
                //This is happening because the parameters order of the (mul) operation changes the matrix, the matrix is either be transposed
                //or not, so we can change it to something we will write below this
                o.normal = mul(v.normals, (float3x3)unity_WorldToObject);

                o.normal = mul((float3x3)unity_ObjectToWorld, v.normals);
                //^this statement clears the confusion and we have changed the order as well

                //we can also use another way to do this
                //UNITY_MATRIX_M is the model matrix which is the MVP (Model, View, Projector) matrix which is equivalent to unity_ObjectToWorld
                //But unity recommend devs to use Unity's provided methods to enable unity to define it different for different platforms because
                //it can get really complicated when you do it on VR etc
                o.normal = mul((float3x3)UNITY_MATRIX_M, v.normals);

                //Note: the same calculation can be done in the fragment shader as well but as it's getting executed for every single pixel
                //every frame, and vertices are way less than that in our case, we should be doing it in vertex shader
                
                return o;
            }
            
            fixed4 frag (Interpolators i) : SV_Target
            {
                return float4(i.normal, 1);
            }
            ENDCG
        }
    }
}
