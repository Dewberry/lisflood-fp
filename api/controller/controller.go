package controller

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type Controller struct {
}

func NewController() *Controller {

	return &Controller{}
}

func (crtl *Controller) Ping(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{"message": "healthy"})
}
