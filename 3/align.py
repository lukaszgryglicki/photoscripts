#!/usr/bin/env python3

import cv2
import numpy as np
import sys
import os

def align_images(source, reference):
    """
    Aligns source image to reference using feature-based registration (ORB keypoints + Homography).
    """
    orb = cv2.ORB_create(5000)  # More features for better alignment

    # Detect keypoints and descriptors
    kp1, des1 = orb.detectAndCompute(source, None)
    kp2, des2 = orb.detectAndCompute(reference, None)

    # Match features
    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
    matches = bf.match(des1, des2)
    matches = sorted(matches, key=lambda x: x.distance)

    if len(matches) < 10:
        raise ValueError("Not enough feature matches for alignment!")

    # Extract matched keypoints
    src_pts = np.float32([kp1[m.queryIdx].pt for m in matches]).reshape(-1, 1, 2)
    dst_pts = np.float32([kp2[m.trainIdx].pt for m in matches]).reshape(-1, 1, 2)

    # Compute Homography
    H, _ = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC, 5.0)

    # Warp image
    aligned = cv2.warpPerspective(source, H, (reference.shape[1], reference.shape[0]), flags=cv2.INTER_LINEAR)
    return aligned

def find_common_region(img1, img2, img3):
    """
    Finds the largest common bounding box among three aligned images.
    """
    mask1 = cv2.threshold(img1, 1, 255, cv2.THRESH_BINARY)[1]
    mask2 = cv2.threshold(img2, 1, 255, cv2.THRESH_BINARY)[1]
    mask3 = cv2.threshold(img3, 1, 255, cv2.THRESH_BINARY)[1]

    common_mask = cv2.bitwise_and(cv2.bitwise_and(mask1, mask2), mask3)

    # Find bounding box of the common region
    contours, _ = cv2.findContours(common_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    x, y, w, h = cv2.boundingRect(contours[0]) if contours else (0, 0, img1.shape[1], img1.shape[0])

    return x, y, w, h

def crop_common_region(img, x, y, w, h):
    """
    Crops the image to the common aligned region.
    """
    return img[y:y+h, x:x+w]

def main():
    if len(sys.argv) != 5:
        print("Usage: python align_images.py <red> <green> <blue> <output_prefix>")
        sys.exit(1)

    red_path, green_path, blue_path, output_prefix = sys.argv[1:5]

    # Load images in grayscale
    red = cv2.imread(red_path, cv2.IMREAD_GRAYSCALE)
    green = cv2.imread(green_path, cv2.IMREAD_GRAYSCALE)  # Reference
    blue = cv2.imread(blue_path, cv2.IMREAD_GRAYSCALE)

    if red is None or green is None or blue is None:
        print("Error: Could not load one or more images!")
        sys.exit(1)

    # Align red and blue channels to green
    red_aligned = align_images(red, green)
    blue_aligned = align_images(blue, green)

    # Find the common region
    x, y, w, h = find_common_region(red_aligned, green, blue_aligned)

    # Crop images to the common region
    red_cropped = crop_common_region(red_aligned, x, y, w, h)
    green_cropped = crop_common_region(green, x, y, w, h)
    blue_cropped = crop_common_region(blue_aligned, x, y, w, h)

    # Save the aligned & cropped images
    cv2.imwrite(f"{output_prefix}_red.png", red_cropped, [cv2.IMWRITE_PNG_COMPRESSION, 9])
    cv2.imwrite(f"{output_prefix}_green.png", green_cropped, [cv2.IMWRITE_PNG_COMPRESSION, 9])
    cv2.imwrite(f"{output_prefix}_blue.png", blue_cropped, [cv2.IMWRITE_PNG_COMPRESSION, 9])

    print(f"Aligned images saved as {output_prefix}_red.png, {output_prefix}_green.png, {output_prefix}_blue.png")

if __name__ == "__main__":
    main()

