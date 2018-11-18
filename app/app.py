from datetime import datetime
from vibora import Vibora, Response

app = Vibora()


@app.route('/')
async def home():
    values = await request.json()
    print(datetime.now(), values)
    return Response(b'Hello world')

@app.route('/ping')
async def home():
    values = await request.json()
    print(datetime.now(), values)
    return Response(b'pong')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80)
