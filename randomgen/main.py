import random, json, functions_framework
from flask import jsonify, abort

@functions_framework.http
def randomgen(request):
  if request.method == 'GET':
    randomNum = random.randint(1,100)
    output = {"random":randomNum}
    return jsonify(output)
  elif request.method == 'PUT':
    return abort(403)
  else:
    return abort(405)