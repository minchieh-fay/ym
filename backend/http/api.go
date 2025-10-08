package http

import (
	"ym/http/common"

	"github.com/gin-gonic/gin"
)

type Api struct {
	common.Common
}

func (a *Api) BindRoute(rg *gin.RouterGroup) {
	rg.GET("/version", a.GetVersion)
}
