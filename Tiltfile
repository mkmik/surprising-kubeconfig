load('ext://ko', 'ko_build')

# Detect host architecture and set KO_DEFAULTPLATFORMS if running on ARM
host_arch = str(local('uname -m')).strip()
if host_arch == 'arm64':
    os.putenv('KO_DEFAULTPLATFORMS', 'linux/arm64')

ko_build('ghcr.io/mkmik/surprising-kubeconfig', '.', deps=['main.go', 'go.mod'])

k8s_yaml(kustomize('manifest/overlays/local'))
