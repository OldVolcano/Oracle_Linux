package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/stretchr/testify/assert"
)

func TestModule(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./fixture",
		Vars: map[string]interface{}{
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)
	
	// Run `terraform output` to get the values of output variables and check they have the expected values.
	// bucket_name := terraform.Output(t, terraformOptions, "bucket_name")
	// assert.Equal(t, "nike-test-bucket", bucket_name)
}
