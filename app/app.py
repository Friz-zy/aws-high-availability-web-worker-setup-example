from vibora import Vibora, Request, Response

app = Vibora()


@app.route('/')
async def home(request: Request):
    return Response(b'Hello world')

@app.route('/ping')
async def ping(request: Request):
    return Response(b'pong')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80)
