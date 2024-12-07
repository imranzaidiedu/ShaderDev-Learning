Shader "Unlit/FirstUnlitShader"
{
    //Making the simplest unlit shader
    Properties //this is input data excluding mesh or lighting information which unity automatically supplies
    {//this properties will show up in editor and you can change it from there
        //_MainTex ("Texture", 2D) = "white" {}
        _Value ("Value", float) = 1.0
    }
    SubShader //This has stuff when it comes to sorting, tags like if this object is opaque or transparent, do we want to change the queue of this so that 
    //it run before or after another shader etc// So this more like render pipeline related info
    {
        Tags { "RenderType"="Opaque" }
        //LOD 100//You can set LOD level of an object and then it will pick different subshader depending on the LOD level

        Pass // this is the section where the shader code goes
        {
            //CGPROGRAM and ENDCG is start and end of shadercode, it says CG, Unity is HLSL but you can call it CG  
            CGPROGRAM
            
            #pragma vertex vert //This is how we tell the compiler that it's a vertex shader function/method and below is a fragment shaer function/method
            #pragma fragment frag //So they are name of the functions defined here

            // make fog work
            //#pragma multi_compile_fog //ignoring it for now

            #include "UnityCG.cginc" //This is takes code from a different file and pastes it into this shader
            //^This is kind of like a library from Unity which contains a lot different unity specific things that we might use
            //to do things more efficiently. There are a lot of built-in functions in it
            //you can add other libraries like maths library to use its methods here

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            //in order to use the property we have defined above in the properties of the shader, we need to also define it here as well
            float _Value;
            
            //This is automatically filled out by unity
            //struct appdata//you can also rename this to have more meaningful name like Mesh data
            struct MeshData //This is per vertex mesh data
            {
                //float4 vertex is a variable name and you can name it however you like it
                //: this colon is called semantic
                //POSITION is what's coming from the compiler that we are trying to map this position data onto the vertex variable we've declared
                float4 vertex : POSITION; //vertex position
                float4 uv : TEXCOORD0; //uv coordinates//These are incredibely general, you can use it for almost anything but quite often they are used
                //to mapping coordinates to objects
                //float2 uv1 : TEXCOORD1; //You can add more texcords to get more texture data like light maps, height maps etc
                //you can have many UV channels
                //float3 normals : NORMAL; //this is the direction that vertex is pointing to
                //float4 color : COLOR; //this is to get the vertex color
                //float4 tangents : TANGENT; //tangents are used with normals to provide more details to surface without adding geometry
                //The first three values in tangent is the direction of the tangent and forth is to save that weather or not it's flipped or UV's are mirrored
                //Normally we only take position and uvcoordinates when working on mesh data as we don't require other properties
            };

            //struct v2f//this is unity's default name for the data that gets passed from the vertex shader to the fragment shader
            //you can name it however you want it to make more sense to you. Naming this to Interpolators
            //The reason we are calling this Interpolators is that when a vertex shader pass the information to the fragment shader
            //if the fragment/pixel lies between two vertexes, the passed data will be interpolated the normal for that fragment to
            //show the right normal
            //For example if the color of one vertex is red and other is blue then the fragment that is in the middle of these two
            //vertex will show a bit of purple color in the middle
            //This is called barycentric interpolation
            struct Interpolators
            {
                //In this part, this TEXCOORD0 is not a UV channel data which can be really confusing
                //This is just for passing data. So you can have as much of this as you want becuase this will be used to pass
                //data from vertex shader to fragment shader
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)//ignoring this for now
                float4 vertex : SV_POSITION; //clip space position of each vertex
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                //This UnityObjectToClipPos function is provided by Unity which in technical terms is multipliying by the MVP(model view projection) matrix
                //In simple words, it converts vertex's local space to clip space and then is sends back the interpolator
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex); //ignoring textures for now
                //UNITY_TRANSFER_FOG(o,o.vertex);//ignoring fog for now
                return o;
            }
            

            //float4 is like Vector4 some goes with float3 and float2
            //But in shader, there are some extra data types that have lower percision than floating point percision
            //So float is 32bit float// this works good with things related to world space etc
            //half is 16 bit float //this is pretty good for most of the things
            //fixed is sround 12 bit float but it's size is different for different platforms
            //fixed is legacy and some platforms have stopped supporting fixed
            //We use fixed only tof values ranging from -1 to 1 because outside of that it gives teribble percision that it's not usefull
            //Note: some platforms(pc like etc) don't use half and fixed at all but for mobile, half works fine. So to be extra safe, we can use float everywhere
            //for vector like ->  float4 -> half4 -> fixed4
            //for matrix like -> float4x4 -> half4x4 -> fixed4x4 (in C# this is equivalent to Matrix4x4)
            //bool can work like 0 1 with true and false. bool2, bool3, bool4
            //int is also available in shaders. int2, int3, int 4
            //The benifits of using lower percision data types can help in doing faster calculations and uses less memory as well. Also when doing GPU instancing,
            //the number of bits that your properties can take determines how many instances you can have in a single batch

            //Note: Only use lower percision data types if you really know what you are doing and you are aware of its limitations across different platforms
            //and your requirements


            //This is fragment shader part
            fixed4 frag (Interpolators i) : SV_Target //this semantic means that this fragment shader should output to the frame buffer so that should be the
            {//target of this fragment shader. if you are doing deffered rendering, you can write to multiple targets
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv); //skipping this
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);//skipping this for now
                // return col;
                
                
                return float4(1,0,0,1);//return red color
            }
            ENDCG
        }
    }
}
