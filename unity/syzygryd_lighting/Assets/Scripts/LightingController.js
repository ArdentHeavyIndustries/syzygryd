// LightingController.js

class Arm {
    var syzLights : ArrayList;

    function Arm() {
        syzLights = new ArrayList();
    }
}

private var arms : ArrayList;

private var tcpInput0 : TcpInput;
private var tcpInput1 : TcpInput;
private var tcpInput2 : TcpInput;

private var kNumLights : int;

function Awake() {
    kNumLights = 36;

    for (var input : TcpInput in GetComponents(TcpInput)) {
        if (input.armNum == 0) {
            tcpInput0 = input;
        } else if (input.armNum == 1) {
            tcpInput1 = input;
        } else if (input.armNum == 2) {
            tcpInput2 = input;
        } else {
            Debug.Log ("Error initializing tcpInput scripts!");
        }
    }
}

function Start() {
    arms = new ArrayList();

    var lightNum = 1;
    
    for (var i = 0; i < 3; i++) {
        var arm : Arm = new Arm();

        for (var j = 0; j < kNumLights; j++) {
            //syzLight.color = Color(0.5, 0.5, 0.5);
            var lightName = "light" + lightNum + "_None";
            lightNum++;
            var syzLight : GameObject = gameObject.Find(lightName); 
            syzLight.renderer.castShadows = false;
            syzLight.renderer.receiveShadows = false;

            arm.syzLights.Add (syzLight);
        }

        arms.Add(arm);
    }
    
}

function Update () {
    for (var i = 0; i < 3; i++) {
        var arm = arms[i];
        for (var j = 0; j < kNumLights; j++) {
            var syzLight = arms[i].syzLights[j];
            //syzLight.gameObject.renderer.material.color = syzLight.color;
            var c : Color;
            if (i == 0) {
                c = tcpInput0.GetLightColor(j);
            } else if (i == 1) {
                c = tcpInput1.GetLightColor(j);
            } else if (i == 2) {
                c = tcpInput2.GetLightColor(j);
            }
            syzLight.renderer.material.color = c;
            syzLight.renderer.material.SetColor("_Emission", c);
            syzLight.renderer.material.SetColor("_SpecColor", c);
        }
    }
}

