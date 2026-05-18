import json
import uvicorn
import time
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from src.pipeline.realtime_pipeline import RealtimePipeline
from src.pose.extractor import PoseExtractor

app = FastAPI()

# Initialize pipeline once to keep state (reps, exercise locked, etc.)
pipeline = RealtimePipeline(use_camera=False)

class LandmarkProxy:
    """Helper to make JSON dicts look like MediaPipe landmark objects for your original code."""
    def __init__(self, d: dict):
        self.x = d["x"]
        self.y = d["y"]
        self.z = d.get("z", 0.0)
        self.visibility = d.get("visibility", d.get("likelihood", 1.0))

@app.websocket("/ws/{session_id}")
async def workout_ws(websocket: WebSocket, session_id: str):
    global pipeline
    await websocket.accept()
    print(f"[+] Client Connected: {session_id}")

    # Fresh start every time a client connects
    pipeline.full_reset()
    print("[+] Pipeline reset for new session")

    # Immediate JSON so Flutter knows we're ready
    await websocket.send_json({
        "state": "CONNECTED",
        "exercise": "WAITING",
        "reps": 0,
        "stage": None,
        "locked": False,
        "confidence": 0.0,
        "feedback": [],
        "awaiting_decision": False,
        "show_report": False,
    })

    try:
        import struct
        while True:
            # Receive either Text (JSON) or Bytes (Binary Keypoints)
            message = await websocket.receive()
            
            if "text" in message:
                msg = json.loads(message["text"])
                # --- Handle Commands from Mobile ---
                cmd = msg.get("command")
                if cmd == "resume":
                    pipeline.session.awaiting_decision = False
                    pipeline.last_rep_time = time.time()
                    print("[>] Session Resumed")
                    await websocket.send_json(pipeline.current_state)
                    continue
                elif cmd == "finish":
                    report = pipeline.session.generate_report()
                    print(f"[!] Session Finished - Report: {report}")
                    pipeline.session.show_report = True
                    pipeline.session.awaiting_decision = False
                    await websocket.send_json({"type": "REPORT", "data": report})
                    continue
                elif cmd == "restart":
                    # Save current round before resetting
                    pipeline.session.restart_session(pipeline)
                    print("[~] Session Restarted (history preserved)")
                    await websocket.send_json(pipeline.current_state)
                    continue

            elif "bytes" in message:
                # Optimized Binary Path
                raw_bytes = message["bytes"]
                if len(raw_bytes) == 528: # 132 float32 * 4 bytes
                    # Unpack 132 floats
                    keypoints_flat = struct.unpack('132f', raw_bytes)
                    
                    lm_proxies = []
                    for i in range(0, 132, 4):
                        lm_proxies.append(LandmarkProxy({
                            "x": keypoints_flat[i],
                            "y": keypoints_flat[i+1],
                            "z": keypoints_flat[i+2],
                            "likelihood": keypoints_flat[i+3]
                        }))
                    
                    features = PoseExtractor._extract_selected_keypoints(lm_proxies)
                    result = pipeline.process_keypoints(features, lm_proxies)
                    await websocket.send_json(result)
                
    except WebSocketDisconnect:
        print(f"[-] Client Disconnected")
    except Exception as e:
        print(f"[-] Error: {e}")
    finally:
        pass

if __name__ == "__main__":
    uvicorn.run("api:app", host="0.0.0.0", port=8000, reload=False)
