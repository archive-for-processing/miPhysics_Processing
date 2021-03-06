PhyModel createBell() {
  PhyModel mdl = new PhyModel("bell", phys.getGlobalMedium());

  int nbRev = 20;
  double R = 50;
  float angle = 0;
  int layers = 7;
  double floor = 10;

  double K = 0.13;
  double Z = 0.00002;

  ArrayList<ArrayList<Mass>> modHolder = new ArrayList<ArrayList<Mass>>();

  for (int lay = 0; lay < layers; lay++) {
    ArrayList<Mass> thisLevel = new ArrayList<Mass>();
    modHolder.add(thisLevel);

    for (int i = 0; i < nbRev; i++) {
      angle += 2.*PI/nbRev;  
      if ((lay == layers -1) && ((i%4) ==0))
        modHolder.get(lay).add(mdl.addMass("m_"+lay+"_"+i, new Ground3D(2, new Vect3D(R*cos(angle), R*sin(angle), lay * floor))));
      else
        modHolder.get(lay).add(mdl.addMass("m_"+lay+"_"+i, new Mass3D(1-0.01*lay, 2, new Vect3D(R*cos(angle), R*sin(angle), lay * floor))));
    }

    for (int i = 0; i < thisLevel.size(); i++) {
      Mass m1 = thisLevel.get(i);
      Mass m2 = thisLevel.get((i+1) % thisLevel.size());
      Mass m3 = thisLevel.get((i+2) % thisLevel.size());

      double dist = m1.getPos().dist(m2.getPos());
      mdl.addInteraction("sp_"+lay+"_"+i+"_a", new SpringDamper3D(dist, K, Z), m1, m2);

      dist = m1.getPos().dist(m3.getPos());
      mdl.addInteraction("sp_"+lay+"_"+i+"_b", new SpringDamper3D(dist, K, Z), m1, m3);
    }
    R = R * (0.9 + 0.005*lay*lay - 0.08*lay);
  }

  for (int lay = 0; lay < layers - 1; lay++) {
    ArrayList<Mass> level = modHolder.get(lay);
    ArrayList<Mass> n1 = modHolder.get(lay+1);

    for (int i = 0; i < level.size(); i++) {
      Mass m1 = level.get(i);
      Mass m2 = n1.get(i);
      Mass m4 = n1.get((i+1) % n1.size());

      double dist = m1.getPos().dist(m2.getPos());
      mdl.addInteraction("spup_"+lay+"_"+i+"_a", new SpringDamper3D(dist, K, Z), m1, m2);

      dist = m1.getPos().dist(m4.getPos());
      mdl.addInteraction("spup_"+lay+"_"+i+"_c", new SpringDamper3D(dist, K, Z), m1, m4);
    }
  }

  for (int lay = 0; lay < layers - 2; lay++) {
    ArrayList<Mass> level = modHolder.get(lay);
    ArrayList<Mass> n2 = modHolder.get(lay+2);

    for (int i = 0; i < level.size(); i++) {
      Mass m1 = level.get(i);
      Mass m3 = n2.get(i);

      double dist = m1.getPos().dist(m3.getPos());
      mdl.addInteraction("spup_"+lay+"_"+i+"_b", new SpringDamper3D(dist, K, Z), m1, m3);
    }
  }

  mdl.addInOut("output1", new Observer3D(filterType.HIGH_PASS), mdl.getMass("m_3_0"));
  mdl.addInOut("output2", new Observer3D(filterType.HIGH_PASS), mdl.getMass("m_2_0"));
  return mdl;
}



PhyModel createHammer() {
  PhyModel mdl = new PhyModel("hammer", phys.getGlobalMedium());

  mdl.addMass("perc", new Osc3D(10, 15, 0.00001, 0.01, new Vect3D(5, 100, 25)), new Medium(0, new Vect3D(0, 0, 0))); 
  mdl.addInOut("drive", new Driver3D(), "perc");

  return mdl;
}
