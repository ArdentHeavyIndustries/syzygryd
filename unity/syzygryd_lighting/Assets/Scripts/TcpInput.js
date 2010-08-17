// TcpInput.js

import System;
import System.Net;
import System.Net.Sockets;
import System.Text;
import System.Threading;

var portNum = 3333;
var armNum = 0;

private var tcpListener : TcpListener;
private var tcpClient : TcpClient;
private var networkStream : NetworkStream;

private var tmpBuffer : String;
private var lastBuffer : String;
private var lightColors : ArrayList;

private var thread : Thread;

private var kNumLights : int;

function Awake() {
    kNumLights = 36;
    
    tmpBuffer = "";
    lastBuffer = "";
    lightColors = new ArrayList();
    var black = Color(0,0,0);
    for (var i = 0; i < kNumLights; i++) {
        lightColors.Add (black); 
    }
}

function Start() {
    tcpClient = null;

    var localAddr : IPAddress = IPAddress.Parse("127.0.0.1");
    tcpListener = new TcpListener(localAddr, portNum);
    tcpListener.Start();

    tcpListener.BeginAcceptTcpClient(
        new AsyncCallback(DoAcceptTcpClientCallback),
        tcpListener);

    //tcpClient = tcpListener.AcceptTcpClient(); // Blocks;
    //StartCoroutine("DoNetworkInput");
    thread = new Thread(DoNetworkInput); 
    thread.Start();
}

function OnApplicationQuit() {
    //StopCoroutine("DoNetworkInput");
    if (networkStream) networkStream.Close();
    if (tcpClient) tcpClient.Close();
    if (tcpListener) tcpListener.Stop();
}

function DoNetworkInput() {
    while (true) {
        if (!tcpClient || !tcpClient.Connected) {
            continue;
        }
        var message = "";        
        try {
            var b = ReadBytes(1);
            if (b == "7E") {
                // Frame Start
                b = ReadBytes(1);
                if (b == "06") {
                    // Command
                    var channelSize = ReadDMXChannelSize();

                    b = ReadBytes(1); // parity byte
                    ReadDMXLights(armNum, channelSize / 3);
                    
                    b = ReadBytes(1);
                    if (b != "E7") {
                        message = "Error: Frame End not received!";
                        Debug.Log(message);
                        AddToBuffer (message);
                    }
                    UpdateBuffer();
                }
            }
        } catch(e) {
            message = "SocketException: " + e.ToString();
            Debug.Log(message);
            AddToBuffer(message);
            UpdateBuffer();
        } 

        Thread.Sleep(10);
    }
}

function ByteArrayToString (ba : Byte[], length : Number) {
    var hex : StringBuilder = new StringBuilder (length * 2);
    for (var b : Byte in ba) {
        hex.AppendFormat("{0:x2}", b);
    }
    return hex.ToString().ToUpper();
}

function ReadBytes(length : int) {
    var bytes : Byte[] = new Byte[length];
    var i = networkStream.Read(bytes, 0, length);
    var byteString = ByteArrayToString(bytes, i);
    var message = "Received " + i + " bytes: " + byteString;
    Debug.Log(message);
    AddToBuffer(byteString);
    return byteString;
}

function ReadDMXChannelSize() {
    var bytes : Byte[] = new Byte[2];
    var i = networkStream.Read(bytes, 0, 2);

    var byteString = ByteArrayToString(bytes, i);
    var message = "Received " + i + " DMX Channel Size bytes: " + byteString;
    Debug.Log(message);
    AddToBuffer(byteString);

    return bytes[0];
}

function ReadDMXLights(armIndex : int, numLights : int) {
    for (var l = 0; l < numLights; l++) {
        var bytes : Byte[] = new Byte[3];
        var i = networkStream.Read(bytes, 0, 3);

        var byteString = ByteArrayToString(bytes, i);
        var message = "Received " + i + " DMX Color bytes: " + byteString;
        Debug.Log(message);
        AddToBuffer(byteString);

        var r = bytes[0] / 255.0;
        var g = bytes[1] / 255.0;
        var b = bytes[2] / 255.0;

        var color = Color(r, g, b);

        lightColors[l] = color;
    }
}

function GetLightColor(lightIndex : int) : Color {
    return lightColors[lightIndex];
}

function GetLastBuffer() : String {
    return lastBuffer;
}

function DoAcceptTcpClientCallback (ar : IAsyncResult) {
    tcpListener = ar.AsyncState;
    tcpClient = tcpListener.EndAcceptTcpClient(ar);
    networkStream = tcpClient.GetStream();
}

function AddToBuffer(message : String) {
    tmpBuffer += message;
}

function UpdateBuffer() {
    lastBuffer = tmpBuffer;
    tmpBuffer = "";
}

