// ConsoleController.js

private var nextDisplayTime : Number;
private var displayRate : Number;

private var syzLights : GameObject;
private var tcpInput0 : TcpInput;
private var tcpInput1 : TcpInput;
private var tcpInput2 : TcpInput;

function Awake() {
    var syzLights = GameObject.Find("SyzLights");

    for (var input : TcpInput in syzLights.GetComponents(TcpInput)) {
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

    guiText.text = "";
    nextDisplayTime = 0;
    displayRate = 0.2;
}

function Update() {
    if (Time.time > nextDisplayTime) {
        var s : String;
        var dmx0 : String = tcpInput0.GetLastBuffer();
        var dmx1 : String = tcpInput1.GetLastBuffer();
        var dmx2 : String = tcpInput2.GetLastBuffer();        
        dmx0 = FormatString(dmx0);
        dmx1 = FormatString(dmx1);
        dmx2 = FormatString(dmx2);
        s = "DMX 0: " + dmx0 + "\n" +
            "DMX 1: " + dmx1 + "\n" +
            "DMX 2: " + dmx2;
        guiText.text = s;
    }
}

function FormatString(s : String) : String { 
    var result = "";
    for (var i = 0; i < s.Length; i++) {
        if (i % 100 == 0) {
            result += "\n";
        }
        result += s[i];
    }

    return result; 
}

