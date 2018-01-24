﻿Shader "Pupil/Heatmap (Unlit)" 
{
	Properties 
	{
    	_Cubemap ("Reflection Probe", CUBE) = "white" {}
	}

SubShader {
    Tags {"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
    LOD 100

    //ZWrite Off
    //Blend SrcAlpha OneMinusSrcAlpha

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
//            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
    			float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            samplerCUBE _Cubemap;
			float4 _Cubemap_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _Cubemap);
                o.color = v.color;
                return o;
            }

            static const float PI = 3.14159265f;
            static const fixed4 black = fixed4(0,0,0,1);
            float3 NormalForUV (float2 uv)
            {
            	float2 angle = float2( (uv.x-0.5f) * 2.0f * PI, (1.0f - uv.y) * PI );

            	return float3 ( sin(angle.y)*cos(angle.x), cos(angle.y), sin(angle.y)*sin(angle.x) );
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 cubemap = texCUBE(_Cubemap, NormalForUV(i.texcoord));

				return lerp(black,cubemap,i.color.r);
            }
        ENDCG
    }
}

}
