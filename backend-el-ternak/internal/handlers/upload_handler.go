package handlers

import (
	"backend-el-ternak/utils"
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
)

type UploadResponse struct {
	URL string `json:"url"`
}

var s3Client *s3.Client
var awsRegion string
var bucketName string

func InitS3(){
	region := os.Getenv("AWS_REGION")
	bucket := os.Getenv("S3_BUCKET_NAME")

	if region == "" || bucket == "" {
		log.Fatal("region or bucket name are not found")
	}

	awsRegion = region
	bucketName = bucket

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(awsRegion))
	if err != nil {
		log.Fatal("failed get AWS config")
	}

	s3Client = s3.NewFromConfig(cfg)
	log.Print("S3 client initialized successfully")
}

func UploadImageHandler(w http.ResponseWriter, r *http.Request){
	if r.Method != http.MethodPost {
		utils.RespondError(w, http.StatusMethodNotAllowed, "Method tidak diizinkan")
		return
	}

	if err := r.ParseMultipartForm(5 << 20); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "Ukuran file terlalu besar")
		return
	}

	file, header, err := r.FormFile("image")
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "Key image tidak ditemukan")
		return
	}
	defer file.Close()

	ext := filepath.Ext(header.Filename)
	fileName := fmt.Sprintf("%s%s", uuid.NewString(), ext)
	contentType := header.Header.Get("Content-Type")
	
	_, err = s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: &bucketName,
		Key: &fileName,
		Body: file,
		ContentType: &contentType,
	})

	if err != nil {
		log.Printf("Failed to upload to S3, error: %v", err)
		utils.RespondError(w, http.StatusInternalServerError, "Gagal mengupload ke storage")
		return
	}

	fileURL := fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", bucketName, awsRegion, fileName)
	utils.RespondSuccess(w, http.StatusOK, "berhasil mengupload bukti", fileURL)
}