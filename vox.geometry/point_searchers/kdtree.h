// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_KDTREE_H
#define INCLUDE_JET_KDTREE_H

#include "../array_view.h"
#include "../bounding_box.h"
#include "../matrix.h"

#include <vector>

namespace vox {
namespace geometry {

//! Generic k-d tree structure.
template <typename T, size_t K> class KdTree final {
public:
  using Point = Vector<T, K>;
  using BBox = BoundingBox<T, K>;

  //! Simple K-d tree node.
  struct Node {
    //! Split axis if flags < K, leaf indicator if flags == K.
    size_t flags = 0;

    //! \brief Right child index.
    //! Note that left child index is this node index + 1.
    size_t child = kMaxSize;

    //! Item index.
    size_t item = kMaxSize;

    //! Point stored in the node.
    Point point;

    //! Initializes leaf node.
    void initLeaf(size_t it, const Point &pt);

    //! Initializes internal node.
    void initInternal(size_t axis, size_t it, size_t c, const Point &pt);

    //! Returns true if leaf.
    bool isLeaf() const;
  };

  using ContainerType = std::vector<Point>;
  using Iterator = typename ContainerType::iterator;
  using ConstIterator = typename ContainerType::const_iterator;

  using NodeContainerType = std::vector<Node>;
  using NodeIterator = typename NodeContainerType::iterator;
  using ConstNodeIterator = typename NodeContainerType::const_iterator;

  //! Builds internal acceleration structure for given points list.
  void build(const ConstArrayView1<Point> &points);

  //!
  //! Invokes the callback function for each nearby point around the origin
  //! within given radius.
  //!
  //! \param[in]  origin   The origin position.
  //! \param[in]  radius   The search radius.
  //! \param[in]  callback The callback function.
  //!
  void forEachNearbyPoint(const Point &origin, T radius,
                          const std::function<void(size_t, const Point &)> &callback) const;

  //!
  //! Returns true if there are any nearby points for given origin within
  //! radius.
  //!
  //! \param[in]  origin The origin.
  //! \param[in]  radius The radius.
  //!
  //! \return     True if has nearby point, false otherwise.
  //!
  bool hasNearbyPoint(const Point &origin, T radius) const;

  //! Returns index of the nearest point.
  size_t nearestPoint(const Point &origin) const;

  //! Returns the mutable begin iterator of the item.
  Iterator begin();

  //! Returns the mutable end iterator of the item.
  Iterator end();

  //! Returns the immutable begin iterator of the item.
  ConstIterator begin() const;

  //! Returns the immutable end iterator of the item.
  ConstIterator end() const;

  //! Returns the mutable begin iterator of the node.
  NodeIterator beginNode();

  //! Returns the mutable end iterator of the node.
  NodeIterator endNode();

  //! Returns the immutable begin iterator of the node.
  ConstNodeIterator beginNode() const;

  //! Returns the immutable end iterator of the node.
  ConstNodeIterator endNode() const;

  //! Reserves memory space for this tree.
  void reserve(size_t numPoints, size_t numNodes);

private:
  std::vector<Point> _points;
  std::vector<Node> _nodes;

  size_t build(size_t nodeIndex, size_t *itemIndices, size_t nItems, size_t currentDepth);
};

} // namespace vox
} // namespace geometry

#include "kdtree-inl.h"

#endif // INCLUDE_JET_KDTREE_H
