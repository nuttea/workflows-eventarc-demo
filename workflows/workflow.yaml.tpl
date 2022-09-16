main:
  params: [event]
  steps:
  - init:
      assign:
        - project_id: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
        - workflow_id: $${sys.get_env("GOOGLE_CLOUD_WORKFLOW_ID")}
        - bucket: $${project_id + "-" + workflow_id}
  - log_event:
      call: sys.log
      args:
        data: $${event}
  - randomgenFunction:
      call: http.get
      args:
          url: https://randomgen-eximi56q2q-as.a.run.app
          auth:
              type: OIDC
      result: randomgenResult
  - log_randomgen:
      call: sys.log
      args:
        data: $${"Random Generator result =" + string(randomgenResult.body.random)}
  - multiplyFunction:
      call: http.post
      args:
          url: https://multiply-eximi56q2q-as.a.run.app
          auth:
              type: OIDC
          body:
              input: $${randomgenResult.body.random}
      result: multiplyResult
  - logFunction:
      call: http.get
      args:
          url: https://api.mathjs.org/v4/
          query:
              expr: $${"log(" + string(multiplyResult.body.multiplied) + ")"}
      result: logResult
  - floorFunction:
      call: http.post
      args:
          url: https://floor-eximi56q2q-as.a.run.app
          auth:
              type: OIDC
          body:
              input: $${logResult.body}
      result: floorResult
  - returnResult:
      return: $${floorResult}