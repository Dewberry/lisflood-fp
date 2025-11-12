package controller

import (
	"net/http"
	"github.com/labstack/echo/v4"
	"os/exec"
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
	cmd := exec.Command("/usr/local/bin/lisflood", b.ModelDir)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": string(output)})
	}
	return c.JSON(http.StatusOK, map[string]string{"output": string(output)})

}
