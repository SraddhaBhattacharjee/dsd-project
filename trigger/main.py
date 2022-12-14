import json
import google.auth
from google.auth.transport.requests import AuthorizedSession

def cloud_fn_runner(event):
    scoped_credentials = google.auth.default(scopes=['https://www.googleapis.com/auth/cloud-platform'])
    authed_session = AuthorizedSession(scoped_credentials)

    URL = 'https://workflowexecutions.googleapis.com/v1/projects/dsd-fall22/locations/northamerica-northeast1/workflows/load-workflow/executions'
    file_id_dict = { 'bucket': event['bucket'], 'object': event['name'] }
    PARAMS = { 'argument' : json.dumps(file_id_dict) }
    res = authed_session.post(url=URL, json=PARAMS)

    print(res)