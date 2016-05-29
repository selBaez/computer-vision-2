/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

PointCloud<PointNormal>::Ptr computeNormals(PointCloud< PointXYZ>::Ptr cloud) {
    PointCloud<PointNormal>::Ptr cloud_normals(new PointCloud<PointNormal>); // Output datasets
    IntegralImageNormalEstimation< PointXYZ, PointNormal> ne;
    ne.setNormalEstimationMethod(ne.AVERAGE_3D_GRADIENT);
    ne.setMaxDepthChangeFactor(0. 02f);
    ne.setNormalSmoothingSize(10. 0f);
    ne.setInputCloud(cloud);
    ne.compute(*cloud_normals);
    copyPointCloud(*cloud, *cloud_normals);
    return cloud_normals;
}