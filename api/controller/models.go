package controller

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type Model struct {
	ModelDir string `json:"model_dir"`
}

func (ctrl *Controller) HandleRunModel(c echo.Context) error {

	var b Model
	if err := c.Bind(&b); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": err.Error()})
	}
	if b.ModelDir == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Missing the following required field: model_dir"})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Recieved model request for: " + b.ModelDir})

}
