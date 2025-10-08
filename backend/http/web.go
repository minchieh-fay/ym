package http

import (
	//"ym/http/api"

	"ym/define"

	"github.com/gin-gonic/gin"
)

func WebServer(r *gin.Engine) {
	a := Api{}
	a.BindRoute(r.Group("/api"))
	r.Run(":" + define.PORT)
}
