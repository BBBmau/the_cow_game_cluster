# resource "kubernetes_manifest" "gameserver_the_first_cow_game_server" {
#   manifest = {
#     "apiVersion" = "agones.dev/v1"
#     "kind" = "GameServer"
#     "metadata" = {
#       "name" = "the-first-cow-game-server"
#       "namespace" = "default"
#     }
#     "spec" = {
#       "ports" = [
#         {
#           "containerPort" = 6060
# 	  "name" = "default"
# 	  "protocol" = "TCP"
#           "portPolicy" = "Dynamic"
#         },
#       ]
#       "health" = {
# 	"disabled" = "true"	
#       }
#       "template" = {
#         "spec" = {
#           "containers" = [
#             {
#               "image" = "us-west1-docker.pkg.dev/thecowgame/game-images/mmo-server:latest"
#               "name" = "thecowgameserver"
#               "resources" = {
#                 "limits" = {
#                   "cpu" = "20m"
#                   "memory" = "64Mi"
#                 }
#                 "requests" = {
#                   "cpu" = "20m"
#                   "memory" = "64Mi"
#                 }
#               }
#             },
#           ]
#         }
#       }
#     }
#   }
# }
