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

TEST(ColliderSet2, Constructors) {
  auto box1 = Box2::builder().withLowerCorner({0, 1}).withUpperCorner({1, 2}).makeShared();

  auto box2 = Box2::builder().withLowerCorner({2, 3}).withUpperCorner({3, 4}).makeShared();

  auto col1 = RigidBodyCollider2::builder().withSurface(box1).makeShared();

  auto col2 = RigidBodyCollider2::builder().withSurface(box2).makeShared();

  ColliderSet2 colSet1;
  EXPECT_EQ(0u, colSet1.numberOfColliders());

  ColliderSet2 colSet2(Array1<Collider2Ptr>{col1, col2});
  EXPECT_EQ(2u, colSet2.numberOfColliders());
  EXPECT_EQ(col1, colSet2.collider(0));
  EXPECT_EQ(col2, colSet2.collider(1));
}

TEST(ColliderSet2, Builder) {
  auto box1 = Box2::builder().withLowerCorner({0, 1}).withUpperCorner({1, 2}).makeShared();

  auto box2 = Box2::builder().withLowerCorner({2, 3}).withUpperCorner({3, 4}).makeShared();

  auto col1 = RigidBodyCollider2::builder().withSurface(box1).makeShared();

  auto col2 = RigidBodyCollider2::builder().withSurface(box2).makeShared();

  auto colSet1 = ColliderSet2::builder().makeShared();
  EXPECT_EQ(0u, colSet1->numberOfColliders());

  auto colSet2 = ColliderSet2::builder().withColliders(Array1<Collider2Ptr>{col1, col2}).makeShared();
  EXPECT_EQ(2u, colSet2->numberOfColliders());
  EXPECT_EQ(col1, colSet2->collider(0));
  EXPECT_EQ(col2, colSet2->collider(1));

  auto colSet3 = ColliderSet2::builder().build();
  EXPECT_EQ(0u, colSet3.numberOfColliders());
}
