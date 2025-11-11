package controller

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

func (ctrl *Controller) HandleRunModel(c echo.Context) error {

	return c.JSON(http.StatusOK, map[string]string{"message": "healthy"})

}
