Shader "Metasweeper/Terrain" {
  Properties {
    _Color ("Color", Color) = (1,1,1,1)
    _Speed ("Speed", Float) = 0
    _Scale ("Scale", Float) = 1
    _BorderWidth ("_BorderWidth", Float) = 0.1
    _Power ("Power", Float) = 2
    [Vector3] _Movement ("Movement Direction", Vector) = (0,0,0,0)
    [Toggle] _Simplistic ("Simple Border", Float) = 0
    [Toggle] _TaperOff ("Taper Off", Float) = 0
    [Toggle] _Flatten ("Flatten", Float) = 0
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 100


    Pass {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma target 3.0
      #include "UnityCG.cginc"

      fixed4 _Color;
      float _Speed;
      float _Scale;
      float _BorderWidth;
      float _Power;
      float3 _Movement;
      bool _Simplistic;
      bool _TaperOff;
      bool _Flatten;

      struct appdata {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f {
        // float2 uv : TEXCOORD0;
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        float3 worldNormal : TEXCOORD1;
      };

      v2f vert (float4 vertex : POSITION, float3 normal : NORMAL) {
        v2f o;
        o.pos = UnityObjectToClipPos(vertex);
        o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
        o.worldNormal = UnityObjectToWorldNormal(normal);
        return o;
      }

      fixed4 frag (v2f input) : SV_Target {

        // All values picked uniformly at random from [0, 1)
        float4 points[25] = {
          float4(0.3618386676999914, 0.24400217674290503, 0.8440026914598087, 0.00046216252730246765),
          float4(0.7131759443365722, 0.5735116174274153, 0.8363157447233891, 0.1332576753710497),
          float4(0.881952057479815, 0.23971204565408644, 0.9718775746865409, 0.5768417521516609),
          float4(0.8213513759605013, 0.35365773523246813, 0.7923825094850776, 0.7620927483222746),
          float4(0.8559058694476627, 0.5410124745610578, 0.02440146699594492, 0.712908056916645),
          float4(0.14126879935134795, 0.681930450827412, 0.33331869539112513, 0.8525455154134565),
          float4(0.5672958037725413, 0.7470778172036605, 0.4680571973599288, 0.045705290107140195),
          float4(0.09915463859900187, 0.8441653003871727, 0.7941731262099818, 0.9913766303198752),
          float4(0.33220057355213184, 0.7409640650408083, 0.029641382021831086, 0.7993944243571605),
          float4(0.8597222674382627, 0.5571182510695647, 0.5157757804268488, 0.16600336592552958),
          float4(0.1676411657036332, 0.7302271392783568, 0.6004736468354273, 0.742121293535482),
          float4(0.46042028889682385, 0.24186729910221394, 0.549051018773119, 0.25961100452716623),
          float4(0.22843372286570873, 0.34783603298370913, 0.05702453009224118, 0.366954927511026),
          float4(0.6005054464685242, 0.013578269259170606, 0.830844081212688, 0.1537655520199417),
          float4(0.4836741128191844, 0.2680037133776991, 0.013491777815665573, 0.4203978983874199),
          float4(0.07562058963397589, 0.48238682920308507, 0.8189102083020396, 0.09239312889789142),
          float4(0.6855681433845422, 0.34479556995698823, 0.9856157356785711, 0.26528846099329084),
          float4(0.30113565301832024, 0.051456930033106474, 0.8963303143659025, 0.8532791371278223),
          float4(0.9255125317342505, 0.20578043285831527, 0.9254807065301429, 0.19846474125497138),
          float4(0.8386091033710372, 0.6491918872643598, 0.4674289260132338, 0.5129506973476692),
          float4(0.7322880400143987, 0.16652513413099346, 0.6760713144996382, 0.6764834125572319),
          float4(0.5406373191402951, 0.618208375315175, 0.42642825518804717, 0.8991777996279495),
          float4(0.639353651884514, 0.8287896596439717, 0.08893232106378157, 0.29130739368831016),
          float4(0.8376430916699957, 0.622054697833706, 0.9152526422929472, 0.4973255443101565),
          float4(0.21218939279609472, 0.48107733677437436, 0.9098034676229558, 0.09454268775284813)
        };

        float3 worldPos = input.worldPos / _Scale;
        float3 normal = normalize(input.worldNormal);
        

        float minDist = 1;
        float minDist2 = 1;
        float minDist3 = 1;
        float3 minDelta = 0;
        float3 minDelta2 = 0;
        float3 minDelta3 = 0;


        for (int index = 0; index < 24; index++) {
          float modulus = points[index].a + 1;
          float3 p = points[index] + (points[index+1] - 0.5) * _Time.x * _Speed;
          p += _Movement * _Speed * _Time.x;

          float3 delta = p - worldPos;
          if (_Flatten) {
            delta -= normal * dot(delta, normal);
          }
          delta = modulus * (frac(delta / modulus) - 0.5);

          float dist = dot(pow(abs(delta), _Power), 1);
          dist = pow(dist, 1 / _Power);

          if (dist < minDist) {
            minDelta3 = minDelta2;
            minDist3 = minDist2;
            minDelta2 = minDelta;
            minDist2 = minDist;
            minDelta = delta;
            minDist = dist;
          } else if (dist < minDist2) {
            minDelta3 = minDelta2;
            minDist3 = minDist2;
            minDelta2 = delta;
            minDist2 = dist;
          } else if (dist < minDist3) {
            minDelta3 = delta;
            minDist3 = dist;
          }
        }

        float d;

        if (_Simplistic) {
          d = abs(minDist - minDist2);
        } else {
          // Only use if _Power == 2
          // Also best if _Flatten is set to true
          float d3 = abs(dot(minDelta + minDelta3, normalize(minDelta3 - minDelta)));
          float d2 = abs(dot(minDelta + minDelta2, normalize(minDelta2 - minDelta)));
          d = min(d2, d3);
        }

        fixed thickness = _BorderWidth;
        if (_TaperOff) {
          thickness *= 0.2 - input.worldPos.y;
        }
        float voronoiBorder = 1 - smoothstep(thickness, thickness + 0.25*_BorderWidth, d);

        return voronoiBorder * _Color;
      }
      ENDCG
    }
  }
}
