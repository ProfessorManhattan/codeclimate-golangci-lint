package read

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"

	"gopkg.in/yaml.v3"

	"gitlab.com/megabyte-labs/go/cli/bodega/taskfile"
)

// Taskvars reads a Taskvars for a given directory
func Taskvars(dir string) (*taskfile.Vars, error) {
	vars := &taskfile.Vars{}

	path := filepath.Join(dir, "Taskvars.yml")
	if _, err := os.Stat(path); err == nil {
		vars, err = readTaskvars(path)
		if err != nil {
			return nil, err
		}
	}

	path = filepath.Join(dir, fmt.Sprintf("Taskvars_%s.yml", runtime.GOOS))
	if _, err := os.Stat(path); err == nil {
		osVars, err := readTaskvars(path)
		if err != nil {
			return nil, err
		}
		vars.Merge(osVars)
	}

	return vars, nil
}

func readTaskvars(file string) (*taskfile.Vars, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	var vars taskfile.Vars
	return &vars, yaml.NewDecoder(f).Decode(&vars)
}
