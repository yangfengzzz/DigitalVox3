// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/colliders/collider_set.h"
#include "../vox.geometry/colliders/rigid_body_collider.h"
#include "../vox.geometry/surfaces/box.h"
#include <gtest/gtest.h>
#include <vector>

using namespace vox;
using namespace geometry;

TEST(ColliderSet3, Constructors) {
  auto box1 = Box3::builder().withLowerCorner({0, 1, 2}).withUpperCorner({1, 2, 3}).makeShared();

  auto box2 = Box3::builder().withLowerCorner({3, 4, 5}).withUpperCorner({4, 5, 6}).makeShared();

  auto col1 = RigidBodyCollider3::builder().withSurface(box1).makeShared();

  auto col2 = RigidBodyCollider3::builder().withSurface(box2).makeShared();

  ColliderSet3 colSet1;
  EXPECT_EQ(0u, colSet1.numberOfColliders());

  ColliderSet3 colSet3(Array1<Collider3Ptr>{col1, col2});
  EXPECT_EQ(2u, colSet3.numberOfColliders());
  EXPECT_EQ(col1, colSet3.collider(0));
  EXPECT_EQ(col2, colSet3.collider(1));
}

TEST(ColliderSet3, Builder) {
  auto box1 = Box3::builder().withLowerCorner({0, 1, 2}).withUpperCorner({1, 2, 3}).makeShared();

  auto box2 = Box3::builder().withLowerCorner({3, 4, 5}).withUpperCorner({4, 5, 6}).makeShared();

  auto col1 = RigidBodyCollider3::builder().withSurface(box1).makeShared();

  auto col2 = RigidBodyCollider3::builder().withSurface(box2).makeShared();

  auto colSet1 = ColliderSet3::builder().makeShared();
  EXPECT_EQ(0u, colSet1->numberOfColliders());

  auto colSet2 = ColliderSet3::builder().withColliders(Array1<Collider3Ptr>{col1, col2}).makeShared();
  EXPECT_EQ(2u, colSet2->numberOfColliders());
  EXPECT_EQ(col1, colSet2->collider(0));
  EXPECT_EQ(col2, colSet2->collider(1));

  auto colSet3 = ColliderSet3::builder().build();
  EXPECT_EQ(0u, colSet3.numberOfColliders());
}
