package common

import (
	"ym/define"

	"github.com/gin-gonic/gin"
)

type ICommon interface {
	GetVersion(c *gin.Context)
}

type Common struct {
}

func (c *Common) GetVersion(req *gin.Context) {
	// 从define/config.go中获取VERSION
	version := define.VERSION
	req.JSON(200, gin.H{"version": version})
}
