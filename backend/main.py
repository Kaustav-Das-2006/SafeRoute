# backend/main.py
from fastapi import FastAPI, WebSocket
import uvicorn

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "SafeRoute Server is Running!"}

# This is the WebSocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    print("Attempting connection...")
    await websocket.accept()
    print("Connection established!")
    
    try:
        while True:
            # Wait for data from the client (Flutter)
            data = await websocket.receive_text()
            print(f"Received: {data}")
            
            # Send a response back
            await websocket.send_text(f"Server received: {data}")
    except Exception as e:
        print("Connection closed")

if __name__ == "__main__":
    # Host 0.0.0.0 is required for Android Emulator access
    uvicorn.run(app,port=8000)