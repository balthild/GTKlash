package main

import (
	"archive/tar"
	"compress/gzip"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
)

const (
	READING int8 = 0
	DONE int8 = 1
	ERROR int8 = 2
)

type Progress struct {
	Status int8
	Rate float64
}

type ReadCounter struct {
	upstream io.Reader

	progress chan Progress
	total uint64
	current uint64
}

func (rc *ReadCounter) Read(p []byte) (int, error) {
	n, err := rc.upstream.Read(p)

	rc.current += uint64(n)
	rc.progress <- Progress {
		Status: READING,
		Rate: float64(rc.current) / float64(rc.total),
	}

	return n, err
}

func downloadMMDB(path string, ch chan Progress) (err error) {
	defer func() {
		if (err == nil) {
			ch <- Progress {
				Status: DONE,
				Rate: 1.0,
			}
		} else {
			ch <- Progress {
				Status: ERROR,
				Rate: 0.0,
			}
		}
	}()

	const url = "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz"

	// Peek file size
	headResp, err := http.Head(url)
	if err != nil {
		return
	}
	defer headResp.Body.Close()

	size, err := strconv.ParseUint(headResp.Header.Get("Content-Length"), 10, 64)
	if err != nil {
		return
	}

	// Get file
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	rc := &ReadCounter{
		upstream: resp.Body,
		progress: ch,
		total: size,
	}

	// Gzip
	gr, err := gzip.NewReader(rc)
	if err != nil {
		return err
	}
	defer gr.Close()

	// TAR
	tr := tar.NewReader(gr)
	for {
		h, err := tr.Next()
		if err != nil {
			return err
		}

		if !strings.HasSuffix(h.Name, "GeoLite2-Country.mmdb") {
			continue
		}

		f, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			return err
		}
		defer f.Close()

		_, err = io.Copy(f, tr)
		return err
	}
}
